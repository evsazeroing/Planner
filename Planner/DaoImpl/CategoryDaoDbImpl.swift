
import CoreData
import UIKit
import Foundation

// реализация DAO для работы с категориями
class CategoryDaoDbImpl: DictDAO, CommonSearchDAO{


    // для наглядности - типы для generics (можно не указывать явно, т.к. компилятор автоматически получит их из методов)
    typealias Item = Category
    typealias SortType = CategorySortType // enum для получения полей сортировки


    // паттерн синглтон
    static let current = CategoryDaoDbImpl()
    private init(){getAll(sortType: CategorySortType.name)}



    var items:[Item]! // полученные из БД объекты


    // MARK: demo data


    func initDemoCategories(){
        let cat1 = Category(context:context)
        cat1.name = lsDemoCat1
        cat1.checked = true

        let cat2 = Category(context:context)
        cat2.name = lsDemoCat2
        cat2.checked = true

        let cat3 = Category(context:context)
        cat3.name = lsDemoCat3
        cat3.checked = true

        let cat4 = Category(context:context)
        cat4.name = lsDemoCat4
        cat4.checked = true

        let cat5 = Category(context:context)
        cat5.name = lsDemoCat5
        cat5.checked = true

        add(cat1)
        add(cat2)
        add(cat3)
        add(cat4)
        add(cat5)
    }



    // MARK: dao


    // получить все объекты  с сортировкой
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


// возможные поля для сортировки списка категорий
enum CategorySortType:Int{
    case name = 0

    // получить объект сортировки для добавления в fetchRequest
    func getDescriptor(_ sortType:CategorySortType) -> NSSortDescriptor{
        switch sortType {
        case .name:
            return NSSortDescriptor(key: #keyPath(Category.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        }
    }
}
