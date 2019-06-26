
import UIKit

// ячейка для отображения приоритета задачи (редактирование/создание)
class TaskPriorityCell: UITableViewCell {

    @IBOutlet weak var labelTaskPriorityColor: UILabel!
    @IBOutlet weak var labelTaskPriority: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
