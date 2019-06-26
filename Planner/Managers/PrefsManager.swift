
import Foundation
import L10n_swift


// класс для работы с настройками приложения (чтение, запись)
class PrefsManager{

    // названия настроек храним в статичных константах
    let showCompletedTasksKey = "showCompletedTasks"
    let showEmptyPrioritiesKey = "showEmptyPriorities"
    let showTasksWithoutDateKey = "showTasksWithoutDate"
    let showEmptyCategoriesKey = "showEmptyCategories"
    let sortTypeKey = "sortType"
    let langKey = "lang"
    let launchedKey = "launched"

    // синглтон
    static let current = PrefsManager()

    private init(){

        // создать ключи для хранения значений настроек (только при первом запуске)
        UserDefaults.standard.register(defaults: [showEmptyCategoriesKey : true])
        UserDefaults.standard.register(defaults: [showEmptyPrioritiesKey : true])
        UserDefaults.standard.register(defaults: [showCompletedTasksKey : false]) // скрывать завершенные задачи
        UserDefaults.standard.register(defaults: [showTasksWithoutDateKey : true])
        UserDefaults.standard.register(defaults: [sortTypeKey : 0]) // по-умолчанию сортировка по имени
        UserDefaults.standard.register(defaults: [langKey : Locale.preferredLanguages[0]]) // по-умолчанию при первом запуске приложения записываем язык из системы
        UserDefaults.standard.register(defaults: [launchedKey : false])


    }

    // MARK: filter settings

    //  показывать или нет в общем списке задачи, у которых не были указаны категории
    var showEmptyPriorities:Bool{
        get{
            return UserDefaults.standard.bool(forKey: showEmptyPrioritiesKey)
        }
        set{
            UserDefaults.standard.set(newValue, forKey: showEmptyPrioritiesKey)
        }
    }

    //  показывать или нет в общем списке задачи, у которых не были указаны категории
    var showEmptyCategories:Bool{
        get{
            return UserDefaults.standard.bool(forKey: showEmptyCategoriesKey)
        }
        set{
            UserDefaults.standard.set(newValue, forKey: showEmptyCategoriesKey)
        }
    }


    //  показывать или нет завершенные задачи
    var showCompletedTasks:Bool{
        get{
            return UserDefaults.standard.bool(forKey: showCompletedTasksKey)
        }
        set{
            UserDefaults.standard.set(newValue, forKey: showCompletedTasksKey)
        }
    }

    //  показывать или нет в общем списке задачи, у которых не указаны сроки выполнения
    var showTasksWithoutDate:Bool{
        get{
            return UserDefaults.standard.bool(forKey: showTasksWithoutDateKey)
        }
        set{
            UserDefaults.standard.set(newValue, forKey: showTasksWithoutDateKey)
        }
    }

    // MARK: sort settings

    // тип сортировки для списка задач
    var sortType:Int{
        get{
            return UserDefaults.standard.integer(forKey: sortTypeKey)
        }
        set{
            UserDefaults.standard.set(newValue, forKey: sortTypeKey)
        }
    }


    // MARK: lang

    //  текущий язык приложения
    var lang:String{
        get{
            return UserDefaults.standard.string(forKey: langKey)!
        }
        set{
            UserDefaults.standard.set(newValue, forKey: langKey)
        }
    }


    // MARK: launched - первый это запуск приложения или нет

    var launched:Bool{
        get{
            return UserDefaults.standard.bool(forKey: launchedKey)
        }
        set{
            UserDefaults.standard.set(newValue, forKey: launchedKey)
        }
    }
 

}

