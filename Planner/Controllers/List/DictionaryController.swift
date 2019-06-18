

import Foundation
import UIKit


// общий класс для контроллеров по работе со справочными значениями (в данный момент: категории, приоритеты)
// процесс заполнения таблиц будет реализовываться в дочерних классах, в этом классе - весь общий функционал
class DictionaryController<T:CommonSearchDAO>: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating{

    var dictTableView: UITableView!  // ссылка на компонент, нужно заполнять по факту уже из дочернего класса

    var dao:T! // DAO для работы с БД (для каждого справочника будет использоваться своя реализация DAO)

    var currentCheckedIndexPath:IndexPath! // индекс последнего/текущего выделенного элемента (галочка)

    var selectedItem:T.Item! // текущий выбранный элемент (галочка)

    var delegate:ActionResultDelegate! // для передачи выбранного элемента обратно в контроллер

    var searchController:UISearchController! // поисковая область, который будет добавляться поверх таблицы задач

    var searchBarText:String! // текущий текст для поиска

    // для сокращения кода
    var searchBar:UISearchBar{
        return searchController.searchBar
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchController() // инициализаия поискового компонента

        searchBar.searchBarStyle = .prominent

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    // MARK: tableView

    // сам процесс заполнения таблиц будет реализовываться в дочерних классах, в этом классе - только подготовка таблицы

    // количество записей
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dao.items.count
    }


    // выделяет элемент в списке (галочка)
    func checkItem(_ sender:UIView){

        // определяем индекс строки по нажатому компоненту
        let viewPosition = sender.convert(CGPoint.zero, to: dictTableView)
        let indexPath = dictTableView.indexPathForRow(at: viewPosition)!

        let item = dao.items[indexPath.row]

        if indexPath != currentCheckedIndexPath{ // если нажатая строка не была выделена до этого (не стояла галочка)

            selectedItem = item

            if let currentCheckedIndexPath = currentCheckedIndexPath{// снимаем галочку для прошлой выбранной строки (если такая была)
                dictTableView.reloadRows(at: [currentCheckedIndexPath], with: .none) // обновляет только 1 строку (предыдущю выбранную)
            }

            currentCheckedIndexPath = indexPath // запоминаем новый выбранный индекс


        }else{ // если строка уже была выделена - снимаем выделение

            selectedItem = nil
            currentCheckedIndexPath = nil
        }

        // обновляем вид нажатой строки (ставим галочку)
        dictTableView.reloadRows(at: [indexPath], with: .none)

        searchController.isActive = false // если пользователь выбрал справочное значение - автоматически закрывать поисковое окно

    }






    // MARK: dao


    func cancel(){
        navigationController?.popViewController(animated: true) // закрыть контроллер и удалить из navigation stack
    }

    func save(){
        navigationController?.popViewController(animated: true) // закрыть контроллер и удалить из navigation stack
        delegate?.done(source: self, data: selectedItem) // уведомить делегата и передать выбранное значение
    }



    // MARK: search

    // добавление search bar к таблице
    func setupSearchController() {

        searchController = UISearchController(searchResultsController: nil) // searchResultsController: nil - т.к. результаты будут сразу отображаться в этом же view

        searchController.dimsBackgroundDuringPresentation = false // затемнять фон или нет, при поиске (при затменении - не будет доступно выбирать найденную запись)
        // строка поиска будет показываться только для списка (не будет переходить в другой контроллер)

        // для правильного отображения внутри таблицы, подробнее http://www.thomasdenney.co.uk/blog/2014/10/5/uisearchcontroller-and-definespresentationcontext/
        definesPresentationContext = true

        searchBar.placeholder = "Начните набирать название"
        searchBar.backgroundColor = .white

        // обработка действий поиска и работа с search bar - в этом же классе (без этих 2 строк не будет работать поиск)
        searchController.searchResultsUpdater = self // т.к. не используем
        searchBar.delegate = self


        // сразу не показывать segmented controls для сортировки результата (такой подход связан с глюком, когда компоненты налезают друг на друга)
        searchBar.showsScopeBar = false

        // не работает
        searchBar.showsCancelButton = false
        searchBar.setShowsCancelButton(false, animated: false)

        searchBar.searchBarStyle = .minimal

        searchController.hidesNavigationBarDuringPresentation = true // закрытие navigation bar компоенентом поиска


        // из-за бага в работе searchController - применяем разные способы добавления searchBar в зависимости от версии iOS
        if #available(iOS 11.0, *) { // если версия iOS от 11 и выше
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            dictTableView.tableHeaderView = searchBar
        }

    }


    // MARK: must implemented

    // получение всех объектов с сортировкой
    func getAll() -> [T.Item]{
        fatalError("not implemented")
    }

    // поиск объектов с сортировкой
    func search(_ text:String) -> [T.Item]{
        fatalError("not implemented")
    }

    // этот метод должен реализовывать дочерний класс
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("not implemented")
    }


    // Search Delegate


    // при активации текстового окна - записываем последний поисковый текст
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.text = searchBarText
        return true
    }


    // каждое изменение текста
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            searchBar.placeholder = "Начните набирать название"
        }
    }

    // нажимаем на кнопку Cancel
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarText = ""
        getAll() // этот метод должен быть реализован в дочернем классе
        dictTableView.reloadData()
        searchBar.placeholder = "Начните набирать название"
    }


    //  поиск по каждой букве при наборе
    func updateSearchResults(for searchController: UISearchController) {

        if !(searchBar.text?.isEmpty)!{ // искать, только если есть текст
            searchBarText = searchBar.text!
            search(searchBarText) // этот метод должен быть реализован в дочернем классе
            dictTableView.reloadData()  //  обновляем всю таблицу
            currentCheckedIndexPath = nil // чтобы не было двойного выделения значений
            searchBar.placeholder = searchBarText // сохраняем поисковый текст для отображения, если окно поиска будет неактивным
        }

    }



}




