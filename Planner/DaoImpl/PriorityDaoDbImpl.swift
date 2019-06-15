
import Foundation
import UIKit
import CoreData

// реализация DAO для работы с приоритетами
class PriorityDaoDbImpl : Crud{

    // для наглядности - типы для generics (можно не указывать явно, т.к. компилятор автоматически получит их из методов)
    typealias Item = Priority


    // паттерн синглтон
    static let current = PriorityDaoDbImpl()
    private init(){
        items = getAll()
    }


    
    var items:[Item]!



    // MARK: dao

    func getAll() -> [Item] {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()

        do {
            items = try context.fetch(fetchRequest)
        } catch {
            fatalError("Fetching Failed")
        }

        return items
    }



    func delete(_ item: Item) {
        context.delete(item)
        save()
    }



    func addOrUpdate(_ item: Item){
        if !items.contains(item){
            items.append(item)
        }

        save()
    }




 
}
