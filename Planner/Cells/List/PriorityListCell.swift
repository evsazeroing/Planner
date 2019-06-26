
import UIKit

// ячейка для отображения данных приоритета в списке
class PriorityListCell: UITableViewCell {

    @IBOutlet weak var labelPriorityName: UILabel!
    @IBOutlet weak var buttonCheckPriority: UIButton!
    @IBOutlet weak var labelPriorityColor: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
