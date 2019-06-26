
import Foundation
import UIKit
import CoreData

// реализация DAO для работы с приоритетами
class PriorityDaoDbImpl : DictDAO, CommonSearchDAO{

    // для наглядности - типы для generics (можно не указывать явно, т.к. компилятор автоматически получит их из методов)
    typealias Item = Priority
    typealias SortType = PrioritySortType // enum для получения полей сортировки


    // паттерн синглтон
    static let current = PriorityDaoDbImpl()
    private init(){
        getAll(sortType: PrioritySortType.index)

    }


    // MARK: demo data

    func initDemoPriorities(){
        let p1 = Priority(context:context)
        p1.name = lsLowPriority
        p1.index = 1
        p1.color = UIColor.init(red: 104/255, green: 143/255, blue: 173/255, alpha: 1.0) // в формате RGBA

        let p2 = Priority(context:context)
        p2.name = lsNormalPriority
        p2.index = 2
        p2.color = UIColor.init(red: 0/255, green: 197/255, blue: 144/255, alpha: 1.0)

        let p3 = Priority(context:context)
        p3.name = lsHighPriority
        p3.index = 3
        p3.color = UIColor.init(red: 236/255, green: 100/255, blue: 75/255, alpha: 1.0)

        add(p1)
        add(p2)
        add(p3)
    }


    
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


   

    
    // поиск по имени задачи
    func search(text: String, sortType:SortType?) -> [Item] {

        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest() // объект-контейнер для выборки данных

        // объект-контейнер для добавления условий
        var predicate = NSPredicate(format: "name CONTAINS[c] %@", text) // [c] - case insensitive

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

  

    // MARK: util

    // обновляет индексы у объектов в зависимости от расположения в массиве
    func updateIndexes(){
        for (index, item) in items.enumerated(){
            item.index = Int32(index)
        }

        save()

        items = getAll(sortType: .index)
    }




 
}



// возможные поля для сортировки списка приоритетов
enum PrioritySortType:Int{
    case index = 0
    
    // получить объект сортировки для добавления в fetchRequest
    func getDescriptor(_ sortType:PrioritySortType) -> NSSortDescriptor{
        switch sortType {
        case .index:
            return NSSortDescriptor(key: #keyPath(Priority.index), ascending: true)
        }
    }
}

