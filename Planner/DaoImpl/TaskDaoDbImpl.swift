
import Foundation
import UIKit
import CoreData

// реализация DAO для работы с задачами
class TaskDaoDbImpl: CommonSearchDAO{

    // для наглядности - типы для generics (можно нуказывать явно, т.к. компилятор автоматически получит их из методов)
    typealias Item = Task


    // доступ к другим DAO
    let categoryDAO = CategoryDaoDbImpl.current
    let priorityDAO = PriorityDaoDbImpl.current

    var items: [Item]! // актуальные объекты, которые были выбраны из БД


    // синглтон
    static let current = TaskDaoDbImpl()
    private init(){

        getAll() // сразу инициализировать задачи

    }


    // MARK: dao

    func getAll() -> [Item] {

        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest() // объект-контейнер для выборки данных

        do {
            items = try context.fetch(fetchRequest) // выполнение выборки (select)
        } catch {
            fatalError("Fetching Failed")
        }

        return items

    }



    func delete(_ item: Item) {
        context.delete(item)
        save()
    }



    func addOrUpdate(_ item: Item)  {
        if !items.contains(item){
            items.append(item)
        }

        save()
    }


    // поиск по имени задачи
    func search(text: String) -> [Item] {

        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest() // объект-контейнер для выборки данных

        var params = [Any]() // массив параметров любого типа

        // прописываем только само условие (без where)
        var sql = "name CONTAINS[c] %@" // начало запроса, [c] - case insensitive

        params.append(text) // указываем значение параметра

        // объект-контейнер для добавления условий
        var predicate = NSPredicate(format: sql, argumentArray: params) // добавляем параметры в sql

        fetchRequest.predicate = predicate // добавляем предикат в контейнер запроса

        // можно создавать предикаты динамически и использовать нужный

        do {
            items = try context.fetch(fetchRequest) // выполняем запрос с предикатом
        } catch {
            fatalError("Fetching Failed")
        }

        return items


    }



}


