
import UIKit

// кнопка с доп. областью для нажатия
class AreaTapButton: UIButton {

    // область кнопки будет немного больше, чем картинка (для удобства нажатия)
    override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {//
        let margin: CGFloat = 10 // доп. область вокруг кнопки
        let area = bounds.insetBy(dx: -margin, dy: -margin) // установка границей кнопки
        return area.contains(point)
    }

}

