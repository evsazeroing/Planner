
import UIKit

class QuickTaskCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textQuickTask: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        textQuickTask.delegate = self
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
