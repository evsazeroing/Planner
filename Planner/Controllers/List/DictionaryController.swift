

import Foundation
import UIKit


// общий класс для контроллеров по работе со справочными значениями (в данный момент: категории, приоритеты)
// процесс заполнения таблиц будет реализовываться в дочерних классах, в этом классе - весь общий функционал
class DictionaryController<T:DictDAO>: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating{

    var labelHeaderTitleDict:UILabel! // ссылка на фактическую кнопку для выделения/снятия

    var buttonSelectDeselectDict:UIButton! // ссылка на фактическую кнопку для выделения/снятия

    var tableViewDict: UITableView!  // ссылка на компонент, нужно заполнять по факту уже из дочернего класса

    var dao:T! // DAO для работы с БД (для каждого справочника будет использоваться своя реализация DAO)

    var currentCheckedIndexPath:IndexPath! // индекс последнего/текущего выделенного элемента (галочка)

    var selectedItem:T.Item! // текущий выбранный элемент (галочка)

    var delegate:ActionResultDelegate! // для передачи выбранного элемента обратно в контроллер

    var searchController:UISearchController! // поисковая область, который будет добавляться поверх таблицы задач

    var searchBarText:String! // текущий текст для поиска

    var navigationTitle:String! // заголовок

    let sectionList = 0

    var changed = false // были или нет изменения при редактровании справочников (нужно, чтобы лишний раз не обновлять список задач)


    var showMode:ShowMode! // режим отображения значений (просто выбор значения или возможность редактирования) - от этого зависит способы выделения, возможные действия и пр.

    // для сокращения кода (необязательно)
    var count:Int{
        return dao.items.count
    }


    // для сокращения кода
    var searchBar:UISearchBar{
        return searchController.searchBar
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchController() // инициализаия поискового компонента

        searchBar.searchBarStyle = .default


    }


    // MARK: init

    // создать нужные кнопки в панели навигации (в зависимости от режима отображения showMode)
    func initNavBar(){
        navigationController?.setNavigationBarHidden(false, animated: true)

        // в данном режим разрешаем выбирать только одну строку
        if showMode == .select{

            // в параметрах передаем функции, которые будут вызываться по нажатию на кнопки
            createSaveCancelButtons(save: #selector(tapSave), cancel: #selector(tapCancel))

        }else if showMode == .edit{

            // в параметрах передаем функции, которые будут вызываться по нажатию на кнопки
            createAddCloseButtons(add: #selector(tapAdd), close: #selector(tapClose))

        }

        self.title = navigationTitle // название меняется в зависимости от типа действий (редактирование, выбор для задачи)

        // для переноса текста на новую строку (если не будет помещаться)
        labelHeaderTitleDict.lineBreakMode = .byWordWrapping
        labelHeaderTitleDict.numberOfLines = 0
        labelHeaderTitleDict.textColor = UIColor.lightGray

    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    // MARK: tableView

    // сам процесс заполнения таблиц будет реализовываться в дочерних классах, в этом классе - только подготовка таблицы


    // сколько секций в таблице
    func numberOfSections(in tableView: UITableView) -> Int {

        updateTableBackground(tableViewDict, count:count)

        if count == 0 {

            // скрыть компоненты для выделения
            labelHeaderTitleDict.isHidden = true
            buttonSelectDeselectDict.isHidden = true
            return 0 // пустая таблица, без записей
        }

        // если есть данные - показывать контролы
        labelHeaderTitleDict.isHidden = false
        buttonSelectDeselectDict.isHidden = false


        return 1 // секция со списком значений

    }


    // нажатие на строку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showMode == .edit{
            editItemAction(indexPath: indexPath) // в режиме edit - переходим к редактированию
            return
        }


        if showMode == .select{
            checkItem(indexPath) // в режиме select - выбираем элемент (для задачи)
            return
        }
    }


    // количество записей
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dao.items.count
    }


    // удаление строки
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            deleteItem(indexPath)

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    // высота строк
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }




    // выделяет элемент в списке (галочка)
    func checkItem(_ indexPath:IndexPath){

        let item = dao.items[indexPath.row]

        switch showMode {
        case .select: // можно выбирать только одно значение - которое запишется для задачи


            if indexPath != currentCheckedIndexPath{ // если нажатая строка не была выделена до этого (не стояла галочка)

                selectedItem = item

                if let currentCheckedIndexPath = currentCheckedIndexPath{// снимаем галочку для прошлой выбранной строки (если такая была)
                    tableViewDict.reloadRows(at: [currentCheckedIndexPath], with: .none) // обновляет только 1 строку (предыдущю выбранную)
                }

                currentCheckedIndexPath = indexPath // запоминаем новый выбранный индекс


            }else{ // если строка уже была выделена - снимаем выделение

                selectedItem = nil
                currentCheckedIndexPath = nil
            }

            searchController.isActive = false // если пользователь выбрал справочное значение - автоматически закрывать поисковое окно



        case .edit: // можно выбирать несколько значений (влияют на фильтрацию списка задач)

            item.checked = !item.checked // инвертируем значение

            updateItem(item, indexPath: indexPath)

            changed = true

        default:
            fatalError("enum type")
        }

        updateSelectDeselectButton()


        // обновляем вид нажатой строки (ставим галочку)
        tableViewDict.reloadRows(at: [indexPath], with: .none)

    }




    // MARK: dao

    func save(){
        closeController() // закрыть контроллер и удалить из navigation stack
        delegate?.done(source: self, data: selectedItem) // уведомить делегата и передать выбранное значение
    }

    // обновляет значение в БД и списке
    func updateItem(_ item:T.Item, indexPath:IndexPath){
        dao.update(item)
        tableViewDict.reloadRows(at: [indexPath], with: .none)
    }

    // удаляет запись из таблицы и БД
    func deleteItem(_ indexPath:IndexPath){

        dao.delete(dao.items[indexPath.row])
        dao.items.remove(at: indexPath.row) // не забываем удалять также из коллекции

        if count == 0{ // если удаленная строка была последней - удаляем все секции (чтобы полностью очистить экран)
            tableViewDict.deleteSections( [sectionList], with: .left)
        }else{
            tableViewDict.deleteRows(at: [indexPath], with: .left) // удаляем строку с анимацией
        }

        changed = true // указываем, что произошли изменения

        updateSelectDeselectButton()

        updateTableBackground(tableViewDict, count:count)


    }


    /* последовательность действий (чтобы корректно работал компонент tableView):

     1) добавить запись в БД и в коллекцию
     2) если это первая запись - добавляем секцию (которая автоматически обновит свой контент и отобразит добавленную запись)
     если уже были записи - просто добавляем строку (секция уже существует, не нужно ее добавлять)
     */

    func addItem(_ item:T.Item){

        dao.add(item)

        if count == 1{ // если добавляется первая запись - добавить сначала секции (в секции автоматически отбразится добавленная строка, не нужно делать insertRows)

            tableViewDict.insertSections([sectionList] , with: .top)

        }else{

            // добавить новую строку с анимацией

            let indexPath = IndexPath(row: count-1, section: sectionList)

             tableViewDict.insertRows(at: [indexPath], with: .top)

        }

        updateSelectDeselectButton()

        updateTableBackground(tableViewDict, count:count)

    }



    // MARK: SelectDelesect button

    // выделение/снятие элементов
    func selectDeselectItems() {

        // меняем значение у всех объектов коллекции
        if dao.checkedItems().count>0{ // если есть хоть 1 выделенный элемент - снимаем выделение
            dao.items.map(){$0.checked = false}
        }else{
            dao.items.map(){$0.checked = true} // выделяем все элементы
        }

        // обновляем секцию со списком категорий
        tableViewDict.reloadSections([sectionList], with: .none)

        updateSelectDeselectButton()

        changed = true

    }


    // сменить надпись на кнопке или сделать неактивной, если необходимо
    func updateSelectDeselectButton() {

        // для режима select или при неактивной кнопке - выходим
        if showMode == .select || buttonSelectDeselectDict.isEnabled == false{
            return
        }


        let newTitle:String

        // если есть хотя бы 1 выбранная категория - показываем текст "Снять выделение"
        if dao.checkedItems().count>0{
            newTitle = lsDeselectAll
        }else{
            newTitle = lsSelectAll
        }

        if self.buttonSelectDeselectDict.title(for: .normal) != newTitle{ // если название поменялось
            buttonSelectDeselectDict.setTitle(newTitle, for: .normal)
        }

        // устанавливаем активность кнопки

        var enabled:Bool

        if count > 1{
            enabled = true
        }else{
            enabled = false
        }

        buttonSelectDeselectDict.isEnabled = enabled

        if !enabled{
            return
        }

    }


    // MARK: #selectors

    // действия при редактировании справочников
    @objc func tapClose(){

        switch self {
        case is CategoryListController:
            performSegue(withIdentifier: "UpdateTasksCategories", sender: self)

        case is PriorityListController:
            performSegue(withIdentifier: "UpdateTasksPriorities", sender: self)

        default:
            return
        }

    }

    @objc func tapAdd(){
        addItemAction()
    }

    // действия при выборе справочного значения для задачи
    @objc func tapSave() {
        save()
    }

    @objc func tapCancel() {
        cancel()
    }



    // MARK: search

    // добавление search bar к таблице
    func setupSearchController() {

        searchController = UISearchController(searchResultsController: nil) // searchResultsController: nil - т.к. результаты будут сразу отображаться в этом же view

        searchController.dimsBackgroundDuringPresentation = false // затемнять фон или нет, при поиске (при затменении - не будет доступно выбирать найденную запись)
        // строка поиска будет показываться только для списка (не будет переходить в другой контроллер)

        // для правильного отображения внутри таблицы, подробнее http://www.thomasdenney.co.uk/blog/2014/10/5/uisearchcontroller-and-definespresentationcontext/
        definesPresentationContext = true

        searchBar.placeholder = lsStartTypingName
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
            tableViewDict.tableHeaderView = searchBar
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

    // добавление нового элемента
    func addItemAction(){
        fatalError("not implemented")
    }

    // редактирование
    func editItemAction(indexPath:IndexPath){
        fatalError("not implemented")
    }

  


    // Search Delegate


    // при активации текстового окна - записываем последний поисковый текст
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.text = searchBarText
        return true
    }


    // каждое изменение текста
    // в отличие от метода updateSearchResults, здесь пока пользователь не начнет набирать символы (или удалять их) - этот метод не сработает 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            searchBar.placeholder = lsStartTypingName
            getAll() // этот метод должен быть реализован в дочернем классе
            tableViewDict.reloadData()
        }
    }

    // нажимаем на кнопку Cancel
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarText = ""
        getAll() // этот метод должен быть реализован в дочернем классе
        tableViewDict.reloadData()
        searchBar.placeholder = lsStartTypingName
    }


    //  поиск по каждой букве при наборе
    func updateSearchResults(for searchController: UISearchController) {

        if !(searchBar.text?.isEmpty)!{ // искать, только если есть текст
            searchBarText = searchBar.text!
            search(searchBarText) // этот метод должен быть реализован в дочернем классе
            tableViewDict.reloadData()  //  обновляем всю таблицу
            currentCheckedIndexPath = nil // чтобы не было двойного выделения значений
            searchBar.placeholder = searchBarText // сохраняем поисковый текст для отображения, если окно поиска будет неактивным
        }

    }


}




// отличия режимов - в возможностях выделения значений и возврате результата работы (для select - возвращем выбранное значение, для edit - ничего не возвращаем)
enum ShowMode{
    case edit // добавление, редактирование
    case select // выбор значения для задачи
}




