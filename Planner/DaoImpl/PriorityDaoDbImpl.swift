
import Foundation
import UIKit
import CoreData

// реализация DAO для работы с приоритетами
class PriorityDaoDbImpl : CommonSearchDAO{

    // для наглядности - типы для generics (можно не указывать явно, т.к. компилятор автоматически получит их из методов)
    typealias Item = Priority
    typealias SortType = PrioritySortType // enum для получения полей сортировки


    // паттерн синглтон
    static let current = PriorityDaoDbImpl()
    private init(){}


    
    var items:[Item]! // полученные из БД объекты



    // MARK: dao

    // получить все объекты
    func getAll(sortType:SortType?) -> [Item] {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest() // объект-контейнер для выборки данных

        // добавляем поле для сортировки
        if let sortType = sortType{
            fetchRequest.sortDescriptors = [sortType.getDescriptor(sortType)] // в зависимости от значения sortType - получаем нужное поле для сортировки
        }

        do {
            items = try context.fetch(fetchRequest) // выполнение выборки (select)
        } catch {
            fatalError("Fetching Failed")
        }

        return items
    }


    // удаление объекта
    func delete(_ item: Item) {
        context.delete(item)
        save()
    }


    // добавление или обновление объекта (если объект существует - обновить, если нет - добавить)
    func addOrUpdate(_ item: Item){
        if !items.contains(item){
            items.append(item)
        }

        save()
    }



    
    // поиск по имени задачи
    func search(text: String, sortType:SortType?) -> [Item] {

        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest() // объект-контейнер для выборки данных

        var params = [Any]() // массив параметров любого типа

        // прописываем только само условие (без where)
        var sql = "name CONTAINS[c] %@" // начало запроса, [c] - case insensitive

        params.append(text) // указываем значение параметра

        // объект-контейнер для добавления условий
        var predicate = NSPredicate(format: sql, argumentArray: params) // добавляем параметры в sql

        fetchRequest.predicate = predicate // добавляем предикат в контейнер запроса

        // можно создавать предикаты динамически и использовать нужный


        // добавляем поле для сортировки
        if let sortType = sortType{
            fetchRequest.sortDescriptors = [sortType.getDescriptor(sortType)] // в зависимости от значения sortType - получаем нужное поле для сортировки
        }
        

        do {
            items = try context.fetch(fetchRequest) // выполняем запрос с предикатом
        } catch {
            fatalError("Fetching Failed")
        }

        return items


    }

 
}



// возможные поля для сортировки списка приоритетов
enum PrioritySortType:Int{
    case index = 0
    
    // получить объект сортировки для добавления в fetchRequest
    func getDescriptor(_ sortType:PrioritySortType) -> NSSortDescriptor{
        switch sortType {
        case .index:
            return NSSortDescriptor(key: #keyPath(Priority.index), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        }
    }
}

