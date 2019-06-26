
import UIKit

// отображение списка языков
class LangListCell: UITableViewCell {

    @IBOutlet weak var buttonCheck: UIButton!
    @IBOutlet weak var imageFlag: UIImageView!
    @IBOutlet weak var labelLangName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

