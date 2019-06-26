
import UIKit

// ячейка для отображения данных категории в списке
class CategoryListCell: UITableViewCell {

    @IBOutlet weak var labelTaskCount: UILabel!
    @IBOutlet weak var labelCategoryName: UILabel!
    @IBOutlet weak var buttonCheckCategory: UIButton!
    
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
