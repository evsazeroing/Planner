
import Foundation

// справочные значения с возможностью выделения элементов (для фильтрации задач или других целей)
protocol DictDAO: Crud where Item: Checkable{

    func checkedItems() -> [Item] // возвращает выделенные элементы, чтобы отфильтровать по ним список задач

}

extension DictDAO{

    // все выделенные элементы из коллекции
    func checkedItems() -> [Item]{
        return getAll().filter(){$0.checked == true}
    }

}

