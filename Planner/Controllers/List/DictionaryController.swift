

import Foundation
import UIKit


// общий класс для контроллеров по работе со справочными значениями (в данный момент: категории, приоритеты)
// процесс заполнения таблиц будет реализовываться в дочерних классах, в этом классе - весь общий функционал
class DictionaryController<T:Crud>: UIViewController, UITableViewDelegate, UITableViewDataSource{

    var dictTableView: UITableView!  // ссылка на компонент, нужно заполнять по факту уже из дочернего класса

    var dao:T! // DAO для работы с БД (для каждого справочника будет использоваться своя реализация DAO)

    var currentCheckedIndexPath:IndexPath! // индекс последнего/текущего выделенного элемента (галочка)

    var selectedItem:T.Item! // текущий выбранный элемент (галочка)

    var delegate:ActionResultDelegate! // для передачи выбранного элемента обратно в контроллер


    override func viewDidLoad() {
        super.viewDidLoad()
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

    // этот метод должен реализовывать дочерний класс
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("not implemented")
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

    }






    // MARK: dao


    func cancel(){
        navigationController?.popViewController(animated: true) // закрыть контроллер и удалить из navigation stack
    }

    func save(){

        navigationController?.popViewController(animated: true) // закрыть контроллер и удалить из navigation stack

        delegate?.done(source: self, data: selectedItem) // уведомить делегата и передать выбранное значение
    }










}


