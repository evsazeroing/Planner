
import Foundation
import UIKit

extension UIViewController{

    // создает объект для форматирования дат
    func createDateFormatter() -> DateFormatter{

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none // не показывать время

        return dateFormatter

    }


    // закрывает контроллер в зависимости от того, как его открыли (модально или через navigation controller)
    func closeController(){
        if presentingViewController is UINavigationController { // если открыли как контроллер без исп. стека
            dismiss(animated: true, completion: nil) // просто скрываем
        }
        else if let controller = navigationController{ // если открыли с navigation controller
            controller.popViewController(animated: true) // удалить из стека контроллеров
        }
        else {
            fatalError("can't close controller")
        }
    }


    // определяет текст для разницы в днях и стиль для Label
    func handleDaysDiff(_ diff:Int?, label:UILabel) {

        label.textColor = .lightGray // цвет по-умолчанию

        var text:String = ""

        if let diff = diff{

            // указываем текст в зависимости от разницы в днях
            switch diff {
            case 0:
                text = "Сегодня" // TODO: локализация
            case 1:
                text = "Завтра"
            case 1...:
                text = "\(diff) дн."
            case ..<0:
                text = "\(diff) дн."
                label.textColor = .red
            default:
                text = ""
            }
        }

        label.text = text

    }


}
