
import UIKit

// ячейка для отображения данных приоритета в списке
class PriorityListCell: UITableViewCell {

    @IBOutlet weak var labelTaskCount: UILabel!
    @IBOutlet weak var labelPriorityName: UILabel!
    @IBOutlet weak var buttonCheckPriority: UIButton!
    @IBOutlet weak var labelPriorityColor: UILabel!
    
    @IBOutlet weak var labelMoveIcon: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        labelTaskCount.roundLabel() // закругляем label
       

    }

    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
