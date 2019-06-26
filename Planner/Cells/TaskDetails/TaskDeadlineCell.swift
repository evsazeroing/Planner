

import UIKit

// ячейка для отображения даты завершения задачи (редактирование/создание)
class TaskDeadlineCell: UITableViewCell {

    @IBOutlet weak var buttonClearDeadline: AreaTapButton!
    @IBOutlet weak var buttonDatetimePicker: UIButton!
    @IBOutlet weak var labelDaysDiff: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
