

import UIKit

// ячейка для отображения пунктов бокового меню
class SideMenuCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // фон для ячейки при нажатии
    @IBInspectable var selectionColor: UIColor = .gray { // @IBInspectable - можно будет задавать настройку через IB
        didSet {
            setBackground()
        }
    }

    // установка фонового цвета
    private func setBackground() {
        let view = UIView()
        view.backgroundColor = selectionColor
        selectedBackgroundView = view
    }

}
