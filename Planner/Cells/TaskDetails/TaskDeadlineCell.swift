

import UIKit

class TaskDeadlineCell: UITableViewCell {

    @IBOutlet weak var labelTaskDeadline: UILabel!
    @IBOutlet weak var buttonClearDeadline: AreaTapButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
