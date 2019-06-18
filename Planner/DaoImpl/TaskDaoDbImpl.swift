
import Foundation
import UIKit
import CoreData

// реализация DAO для работы с задачами
class TaskDaoDbImpl: CommonSearchDAO{

    // для наглядности - типы для generics (можно нуказывать явно, т.к. компилятор автоматически получит их из методов)
    typealias Item = Task
    typealias SortType = TaskSortType // enum для получения полей сортировки


    // доступ к другим DAO
    let categoryDAO = CategoryDaoDbImpl.current
    let priorityDAO = PriorityDaoDbImpl.current

    var items: [Item]! // актуальные объекты, которые были выбраны из БД


    // синглтон
    static let current = TaskDaoDbImpl()
    private init(){}


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
    func addOrUpdate(_ item: Item)  {
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

// возможные поля для сортировки списка задач
enum TaskSortType:Int{
    // порядок case'ов должен совпадать с порядком кнопок сортировки (scope buttons)
    case name = 0
    case priority
    case deadline

    // получить объект сортировки для добавления в fetchRequest
    func getDescriptor(_ sortType:TaskSortType) -> NSSortDescriptor{
        switch sortType {
        case .name:
            return NSSortDescriptor(key: #keyPath(Task.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        case .deadline:
            return NSSortDescriptor(key: #keyPath(Task.deadline), ascending: true)
        case .priority:
            return NSSortDescriptor(key: #keyPath(Task.priority.index), ascending: false) // ascending: false - в начале списка будут важные задачи
        }
    }

}


