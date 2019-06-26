
import UIKit

// ячейка для быстрого создания задачи
class QuickTaskCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textQuickTask: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        textQuickTask.delegate = self // действия для текстового поля будем обрабатывать в текущем классе (без этого не будет работать)

       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // когда пользователь нажимает кнопку Return (Enter) на клавиатуре
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textQuickTask.resignFirstResponder() // скрыть фокус с текстового поля (клавиатура исчезнет)
        return true
    }

}
