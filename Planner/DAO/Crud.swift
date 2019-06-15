
import Foundation
import CoreData

// CRUD API для работы с сущностями (общие операции для всех объектов)
protocol Crud{

    associatedtype Item : NSManagedObject // NSManagedObject - чтобы объект можно было записывать в БД

    var items:[Item]! {get set} // текущая коллекция объектов для отображения

    func addOrUpdate(_ item:Item) // добавляет новый объект или обновляет существующий

    func getAll() -> [Item] // получение списка

    func delete(_ item: Item) // удаление объекта

}


