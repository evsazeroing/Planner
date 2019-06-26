
import Foundation

// поиск задач с учетом фильтрации
protocol TaskSearchDAO : Crud{

    associatedtype CategoryItem: Category // любая реализация Category
    associatedtype PriorityItem: Priority // любая реализация Priority


    // поиск по тексту + фильтрация + сортировка
    func search(text:String?, categories:[CategoryItem], priorities:[PriorityItem], sortType:SortType?, showTasksEmptyCategories:Bool, showTasksEmptyPriorities:Bool, showCompletedTasks:Bool, showTasksWithoutDate:Bool) -> [Item]
}
