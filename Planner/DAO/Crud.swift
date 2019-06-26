
import Foundation
import CoreData
import UIKit

// CRUD API для работы с сущностями (общие операции для всех объектов)
protocol Crud: class { // class указываем для того, чтобы только классы (не struct) могли использовать этот протокол (reference type), иначе extension Crud (ниже) будет выдавать ошибку компиляции при попытке изменить переменную

    associatedtype Item : NSManagedObject // NSManagedObject - чтобы объект можно было записывать в БД

    associatedtype SortType // тип сортировки (для каждого объекта свои поля сортировки)

    var items:[Item]! {get set} // текущая коллекция объектов для отображения

    func addOrUpdate(_ item:Item) // добавляет новый объект или обновляет существующий

    func add(_ item:Item) // добавляет новый объект (отдельный метод)

    func update(_ item:Item) // обновляет существующий (отдельный метод)

    func getAll(sortType:SortType?) -> [Item] // получение списка с сортировкой (если значение sortType = nil, выборка без сортировки)

    func getAll() -> [Item] // получить все значения без сортировки

    func delete(_ item: Item) // удаление объекта

}



// реализации по-умолчанию для интерфейсов
// обычно расширения для протоколов находятся в том же файле, что и сам протокол
extension Crud{

    // контекст для работы с БД, создания новых объектов-entity и пр.
    var context:NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    // сохранение всех изменений контекста
    func save(){
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    // MARK: default impls

    // удаление объекта
    func delete(_ item: Item) {
        context.delete(item)
        save()
    }

  
    // добавление или обновление объекта (если объект существует - обновить, если нет - добавить)
    func addOrUpdate(_ item: Item){
        if !items.contains(item){
            add(item)
        }

        save()
    }


    // добавление объекта
    func add(_ item:Item){
        items.append(item)

        // описание возможной проблемы https://www.bignerdranch.com/blog/protocol-oriented-problems-and-the-immutable-self-error/
        save()
    }

    // добавление объекта
    func update(_ item:Item){
        save()
    }


    // получить все объекты без сортировки
    func getAll() -> [Item] {

        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest() as! NSFetchRequest<Self.Item> // объект-контейнер для выборки данных

        do {
            items = try context.fetch(fetchRequest) // выполнение выборки (select)
        } catch {
            fatalError("Fetching Failed")
        }

        return items

    }


}

