
import UIKit

// ячейка для отображения категории задачи (редактирование/создание)
class TaskCategoryCell: UITableViewCell {

    @IBOutlet weak var labelTaskCategory: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
