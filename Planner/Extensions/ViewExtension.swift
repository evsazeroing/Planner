
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
