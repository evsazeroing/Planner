
import CoreData
import UIKit
import Foundation

// реализация DAO для работы с категориями
 class CategoryDaoDbImpl: Crud{


    // для наглядности - типы для generics (можно не указывать явно, т.к. компилятор автоматически получит их из методов)
    typealias Item = Category


    // паттерн синглтон
    static let current = CategoryDaoDbImpl()
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
        // удаление из коллекции происходит в контроллере, т.к. там легче удалять по индексу
        save()
    }



     func addOrUpdate(_ item:Item){

        if !items.contains(item){
            items.append(item)
        }

        save()

    }





}

