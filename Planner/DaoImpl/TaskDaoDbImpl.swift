
import Foundation
import UIKit
import CoreData

// реализация DAO для работы с задачами
class TaskDaoDbImpl: TaskSearchDAO{

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


    // поиск по имени задачи с учетом фильтрации, сортировки и пр.
    func search(text:String?, categories:[Category], priorities:[Priority],  sortType:SortType?, showTasksEmptyCategories:Bool, showTasksEmptyPriorities:Bool, showCompletedTasks:Bool, showTasksWithoutDate:Bool) -> [Item]{

        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest() // объект-контейнер для выборки данных

        var predicates = [NSPredicate]()  // будет хранить все условия

        if let text = text{

            // упрощенная запись предиаката (без массива параметров и отдельной переменной для SQL)
            predicates.append(NSPredicate(format: "name CONTAINS[c] %@", text)) // [c] = Case Insensitive, текст SQL в синтаксисе Swift

        }

        // фильтрация по категориям

        if !categoryDAO.items.isEmpty{ // если есть записи (может быть так, что все удалены) - иначе категории не будут участвовать в фильтрации

            if categories.isEmpty{ // все значения "отжаты" (на сами категории существуют)

                if showTasksEmptyCategories{ // если нужно показывать задачи с пустой категорией
                    predicates.append(NSPredicate(format: "(NOT (category IN %@) or category==nil)", categoryDAO.items)) // показывать задачи, которые не включают ни одну из категорий (т.к. все значения "отжаты")
                }else{
                    predicates.append(NSPredicate(format: "(NOT (category IN %@) and category!=nil)", categoryDAO.items))
                }

            }else{ // выбраны какие-либо значения для фильтрации (не все "отжато")
                if showTasksEmptyCategories{
                    predicates.append(NSPredicate(format: "(category IN %@ or category==nil)", categories))
                }else{
                    predicates.append(NSPredicate(format: "(category IN %@ and category!=nil)", categories))
                }
            }

        }

        // фильтрация по приоритетам

        if !priorityDAO.items.isEmpty{

            if priorities.isEmpty{

                if showTasksEmptyPriorities{
                    predicates.append(NSPredicate(format: "(NOT (priority IN %@) or priority==nil)", priorityDAO.items))
                }else{
                    predicates.append(NSPredicate(format: "(NOT (priority IN %@) and priority!=nil)", priorityDAO.items))
                }

            }else{
                if showTasksEmptyPriorities{
                    predicates.append(NSPredicate(format: "(priority IN %@ or priority==nil)", priorities))
                }else{
                    predicates.append(NSPredicate(format: "(priority IN %@ and priority!=nil)", priorities))
                }
            }

        }



        // не показывать задачи без приоритета
        if !showTasksEmptyPriorities{
            predicates.append(NSPredicate(format: "priority != nil"))
        }

        // не показывать завершенные задачи
        if !showCompletedTasks{
            predicates.append(NSPredicate(format: "completed != true"))
        }

        // не показывать задачи без даты
        if !showTasksWithoutDate{
            predicates.append(NSPredicate(format: "deadline != nil"))
        }




        // собираем все предикаты (условия)
        // where добавлять вручную нигде добавлять не нужно (Core Data сам построит правильный запрос)
        let allPredicates = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicates) // все предикаты будут с условием И (AND)


        // объект-контейнер для добавления условий
        fetchRequest.predicate = allPredicates // добавляем все предикаты в контейнер запроса


        // добавляем поле для сортировки
        if let sortType = sortType{
            fetchRequest.sortDescriptors = [sortType.getDescriptor(sortType)] // в зависимости от значения sortType - получаем нужное поле для сортировки
        }

        

        do {
            items = try context.fetch(fetchRequest) // выполняем окончательный запрос (с предикатами и сортировками, если есть)
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



