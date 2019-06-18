import Foundation
import UIKit

// уведомление другого контроллера о своем действии и передача результата (если необходимо)
// используется, если надо вернуть результат обратно в предыдущий контроллер (чтобы не использовать unwind segue)
protocol ActionResultDelegate{

    // тип Any - чтобы можно было передавать любой тип объекта, главное потом выполнить приведение к нужному типу
    func done(source:UIViewController, data:Any?) // ОК, сохранить

    func cancel(source:UIViewController, data:Any?) // отмена действия

}

// реализации по-умолчанию для интерфейса
// если какой-то метод будет вызван без реализации в конкретном классе - произойдет оишбка fatalError
extension ActionResultDelegate{

    func done(source: UIViewController, data: Any?) {
        fatalError("not implemented")
    }

    func cancel(source: UIViewController, data: Any?) {
        fatalError("not implemented")
    }

}

