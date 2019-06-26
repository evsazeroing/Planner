
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
    private init(){

        if !PrefsManager.current.launched{ // если приложение ни разу на запускалось
            items = [Item]()
            PrefsManager.current.launched = true // записать true, т.к. первый запуск произошел
            initDemoData()
        }

    }


    // MARK: demo data

    // добавить демо данные (при самом первом запуске приложения)
    func initDemoData(){

        // проверка, что все коллекции пустые (чтобы не удалить уже введенные данные)

        if items.count > 0 || categoryDAO.items.count > 0 || priorityDAO.items.count > 0{
            return
        }


        priorityDAO.initDemoPriorities()
        categoryDAO.initDemoCategories()

        initDemoTasks()
        
    }



    func initDemoTasks(){
        let task1 = Task(context:context)
        task1.category = categoryDAO.items[1]
        task1.name = lsDemoTask1
        task1.priority = priorityDAO.items[2]
        task1.info = lsDemoInfo1
        task1.deadline = Date().today

        let task2 = Task(context:context)
        task2.category = categoryDAO.items[3]
        task2.name = lsDemoTask2
        task2.priority = priorityDAO.items[0]
        task2.deadline = Date().rewindDays(1)


        let task3 = Task(context:context)
        task3.category = categoryDAO.items[0]
        task3.name = lsDemoTask3
        task3.priority = priorityDAO.items[2]
        task3.deadline = Date().rewindDays(15)


        let task4 = Task(context:context)
        task4.category = categoryDAO.items[2]
        task4.name = lsDemoTask4
        task4.info = lsDemoInfo4
        task4.priority = priorityDAO.items[1]
        task4.deadline = Date().rewindDays(-10)

        let task5 = Task(context:context)
        task5.category = categoryDAO.items[0]
        task5.name = lsDemoTask5
        task5.info = lsDemoInfo5
        task5.priority = priorityDAO.items[1]
        task5.deadline = Date().rewindDays(2)

        let task6 = Task(context:context)
        task6.category = categoryDAO.items[1]
        task6.name = lsDemoTask6
        task6.info = lsDemoInfo6
        task6.priority = priorityDAO.items[1]
        task6.deadline = Date().rewindDays(2)


        let task7 = Task(context:context)
        task7.category = categoryDAO.items[0]
        task7.name = lsDemoTask7
        task7.priority = priorityDAO.items[1]
        task7.deadline = Date().rewindDays(2)



        let task8 = Task(context:context)
        task8.category = categoryDAO.items[4]
        task8.name = lsDemoTask8
        task8.priority = priorityDAO.items[2]
        task8.deadline = Date().rewindDays(2)


        let task9 = Task(context:context)
        task9.category = categoryDAO.items[3]
        task9.name = lsDemoTask9
        task9.info = lsDemoInfo9
        task9.priority = priorityDAO.items[0]
        task9.deadline = Date().rewindDays(2)


        let task10 = Task(context:context)
        task10.category = categoryDAO.items[3]
        task10.name = lsDemoTask10
        task10.priority = priorityDAO.items[2]
        task10.deadline = Date().rewindDays(2)


        add(task1)
        add(task2)
        add(task3)
        add(task4)
        add(task5)
        add(task6)
        add(task7)
        add(task8)
        add(task9)
        add(task10)


    }


    // MARK: dao



    // получить все объекты с сортировкой
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



