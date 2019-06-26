
import Foundation
import CoreData

// справочные значения с возможностью выделения элементов (для фильтрации задач или других целей)
protocol DictDAO: Crud where Item: Checkable{

    func checkedItems() -> [Item] // возвращает выделенные элементы, чтобы отфильтровать по ним список задач

}

extension DictDAO{

//    // все выделенные элементы из коллекции
//    func checkedItems() -> [Item]{
//        return getAll().filter(){$0.checked == true} // из всех справочных значений выбираем выбранные
//    }

    // вернуть выбранные значения справочников (для сортировки списка задач)
    func checkedItems() -> [Item]{

        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest() as! NSFetchRequest<Self.Item> // объект-контейнер для выборки данных

        // объект-контейнер для добавления условий
        var predicate = NSPredicate(format: "checked=true")

        fetchRequest.predicate = predicate // добавляем предикат в контейнер запроса

        var tmpItems:[Item]

        do {
            tmpItems = try context.fetch(fetchRequest) // выполняем запрос с предикатом
        } catch {
            fatalError("Fetching Failed")
        }

        return tmpItems
    }

}

