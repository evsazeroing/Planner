
import Foundation
import UIKit
import CoreData

// реализации по-умолчанию для интерфейсов
extension Crud{

    var context:NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // контекст для работы с БД
    }

    // сохранение всех изменений контекста
    func save(){
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }


}



