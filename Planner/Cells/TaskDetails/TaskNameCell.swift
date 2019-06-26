
import UIKit

// ячейка для отображения названия задачи (редактирование/создание)
class TaskNameCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textTaskName: UITextField!

    // метод вызывается после инициализации компонента
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        textTaskName.delegate = self // обработку событий для текстого поля будет выполнять текущий класс
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


    // когда пользователь нажимает кнопку Return (Enter) на клавиатуре
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textTaskName.resignFirstResponder() // скрыть фокус с текстового поля (клавиатура исчезнет)
        return true
    }

}
