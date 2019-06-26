
import Foundation
import UIKit

extension UILabel{

    // функция, которая закругляет Label
    func roundLabel(){
        // делаем круглую иконку
        self.layer.cornerRadius = 12 // в IB указали высоту и ширину 24, поэтому cornerRadius = 24/2 = 12
        self.layer.backgroundColor = UIColor(named: "separator")?.cgColor

        self.textAlignment = .center // выравнивание текста

        self.textColor = UIColor.darkGray
    }
}


extension UITextView{

    // ищет URL ссылку при нажатии в текстовом поле, если нашел - открывает ее в браузере
    func findUrl(sender: UITapGestureRecognizer) -> Bool{
        let textView = self
        let tapLocation = sender.location(in: textView)
        let textPosition = textView.closestPosition(to:tapLocation)
        let attr: NSDictionary = textView.textStyling(at:textPosition!, in: UITextStorageDirection.forward)! as NSDictionary

        // если нажали на URL в тексте - открыть в браузере системы
        if let url: NSURL = attr[NSAttributedStringKey.link] as? NSURL {

            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url as URL)
            }

            return true
        }

        return false

    }

}
