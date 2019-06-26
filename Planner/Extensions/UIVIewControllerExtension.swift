
import Foundation
import UIKit

// полезные функции для всех контроллеров
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
                text = lsToday
            case 1:
                text = lsTomorrow
            case 1...:
                text = "\(diff) \(lsDays)."
            case ..<0:
                text = "\(diff) \(lsDays)."
                label.textColor = .red
            default:
                text = ""
            }
        }

        label.text = text

    }


    // диалоговое окно для подтверждения действия
    func confirmAction(text:String, actionClosure:@escaping ()->Void){
        // объект диалогового окна
        let dialogMessage = UIAlertController(title: lsConfirm, message: text, preferredStyle: .actionSheet)

        // создания объектов для действий (ок, отмена)

        // действие ОК
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            actionClosure()
        })

        // действие Отмена
        let cancel = UIAlertAction(title: lsCancel, style: .cancel) { (action) -> Void in
        }

        // добавить действия в диалоговое окно
        dialogMessage.addAction(ok) // закроется диалоговое окно и вызовется segue
        dialogMessage.addAction(cancel) // просто закроется диалоговое окно

        // показать диалоговое окно
        present(dialogMessage, animated: true, completion: nil)
    }

    // показать диалоговое окно
    func showDialog(title:String, message:String, initValue:String = "", actionClosure:@escaping (String)->Void){

         // запускаем асинхронно, чтобы не было задержки при показе диалог. окна (если открыть диалоговое окно в главном потоке - могут бать "лаги" - окно не сразу показывается)
        DispatchQueue.main.async {

            // показываем диалоговое окно с текстовым компонентов для редактирования названия
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert)

            // добавить текстовое поле в диалоговое окно
            alert.addTextField(configurationHandler: nil)

            // добавляем кнопку очистки текстового поля
            alert.textFields?[0].clearButtonMode = .whileEditing

            alert.textFields?[0].text = initValue // начальные текст для отображения

            // добавляем действие для кнопки ОК (само действие может быть любым и берется из замыкания)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:  {(action) -> Void in
                actionClosure(alert.textFields?[0].text ?? "") // передаем в замыкание веденный текст
            }
            ))

            // при нажатии на Отмену - просто закрывается диалоговое окно
            alert.addAction(UIAlertAction(title: lsCancel, style: .cancel, handler: nil))

            // показать диалоговое окно
            self.present(alert, animated: true, completion: nil)

        }
    }


    // добавляет кнопки Добавить и Закрыть (метод используется при выборе справочного значения)
    func createSaveCancelButtons(save: Selector, cancel: Selector = #selector(cancel)){ // если не передавать параметр - по-умолчанию будет вызываться cancel

        // короткая запись создания кнопки
        // реализацию cancel передаем в параметре
        let buttonCancel = UIBarButtonItem(title: lsCancel, style: .plain, target: self, action: cancel)
        navigationItem.leftBarButtonItem = buttonCancel // будет отображаться слева


        // короткая запись создания кнопки
        // реализацию save передаем в параметре
        let buttonSave = UIBarButtonItem(title: lsSave, style: .plain, target: self, action: save)
        navigationItem.rightBarButtonItem = buttonSave // будет отображаться справа


    }

    // добавляет кнопки Сохранить и Отмена (используется при редактировании справочников)
    func createAddCloseButtons(add: Selector, close: Selector = #selector(cancel)){ // если не передавать параметр - по-умолчанию будет вызываться cancel

        let buttonClose = UIBarButtonItem()
        buttonClose.target = self
        buttonClose.action = close
        buttonClose.title = lsClose
        navigationItem.leftBarButtonItem = buttonClose

        // короткая запись создания кнопки
        let buttonAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: add)
        navigationItem.rightBarButtonItem = buttonAdd
    }

    // добавляет только 1 кнопку - Закрыть
    func createCloseButtonOnly(close: Selector = #selector(cancel)){ // если не передавать параметр - по-умолчанию будет вызываться cancel

        let buttonClose = UIBarButtonItem()
        buttonClose.target = self
        buttonClose.action = close
        buttonClose.title = lsClose
        navigationItem.leftBarButtonItem = buttonClose

        navigationItem.rightBarButtonItem = nil
    }

    // по-умолчанию на cancel будет закрываться контроллер (если другой контроллер у себя не переопределит метод)
    @objc func cancel(){
        closeController()
    }

    // проверяет пустое ли значение, с учетом удаления пробелов и перевода каретки
    func isEmptyTrim(_ str:String?) -> Bool{
        if let value = str?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty{
            return false // значит не пусто
        }else{
            return true
        }
    }


    // сообщение, если нет данных (строк)
    func createNoDataView(_ text:String) -> UILabel{
        let messageLabel = UILabel(frame: CGRect(x:0,y:0,width:view.bounds.size.width, height:view.bounds.size.height))
        messageLabel.text = text
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.textColor = UIColor.darkGray
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)

        return messageLabel

    }

    // обновляет фон для таблицы если нет записей
    func updateTableBackground(_ tableView:UITableView, count:Int){
        if count>0 {
            tableView.separatorColor = UIColor(named: "separator") // цвет будет браться из assets
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine

        }else{ // если нет записей
            tableView.separatorStyle = .none // чтобы не было пустых линий
            tableView.backgroundView = createNoDataView(lsNoData) // показать сообщение, что нет данных в таблице
        }
    }


    // если нажали мимо клавиатуры - скрывать ее

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true) // скрыть клавиатуру
    }



   
}
