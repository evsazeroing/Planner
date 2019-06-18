
import Foundation
import CoreData

// CRUD API для работы с сущностями (общие операции для всех объектов)
protocol Crud{

    associatedtype Item : NSManagedObject // NSManagedObject - чтобы объект можно было записывать в БД

    associatedtype SortType // тип сортировки (для каждого объекта свои поля сортировки)

    var items:[Item]! {get set} // текущая коллекция объектов для отображения

    func addOrUpdate(_ item:Item) // добавляет новый объект или обновляет существующий

    func getAll(sortType:SortType?) -> [Item] // получение списка с сортировкой (если значение sortType = nil, выборка без сортировки)
    
    func delete(_ item: Item) // удаление объекта

}


