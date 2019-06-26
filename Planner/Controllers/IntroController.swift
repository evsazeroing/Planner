
import UIKit
import SwiftyOnboard

class IntroController: UIViewController {

    let pageCount = 5
    var swiftyOnboard: SwiftyOnboard! // основной контейнер

    let colors:[UIColor] = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),#colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1),#colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1),#colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)] // можно указывать любые цвета, главное, чтобы с картинкой сочеталось

    // массив с текстами для каждой странице
    var subTitleArray: [String] = [
        lsIntroTaskList,
        lsIntroFilter,
        lsIntroSearch,
        lsIntroDict,
        lsIntroColors
    ]


    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.statusBarStyle = .lightContent // светлый стиль статусбара

        // инициализируем контейнер
        swiftyOnboard = SwiftyOnboard(frame: view.frame, style: .dark)

        view.addSubview(swiftyOnboard) // добавляем отображение слайдов

        // реализации протоколов
        swiftyOnboard.dataSource = self
        swiftyOnboard.delegate = self

    }



    // нажали Пропустить
    @objc func handleBegin() {
        openMainWindow()
    }


    // открыть главное окно
    func openMainWindow(){

        UIView.transition(with: UIApplication.shared.windows[0], duration: 0.5, options: .transitionFlipFromRight, animations: {

            UIApplication.shared.windows[0].rootViewController = VCManager.current.loadVC(name: "FirstNavigationController") //  переходим в главное окно программы
        }, completion: nil)


    }
}

// слушатели событий при различных действиях (переключение страниц
// функции вызываются автоматически при различных действиях компонента
extension IntroController: SwiftyOnboardDelegate, SwiftyOnboardDataSource {

    // общее кол-во страниц
    func swiftyOnboardNumberOfPages(_ swiftyOnboard: SwiftyOnboard) -> Int {
        return pageCount
    }

    // выбор цвета для каждой страницы
    func swiftyOnboardBackgroundColorFor(_ swiftyOnboard: SwiftyOnboard, atIndex index: Int) -> UIColor? {
        return colors[index]
    }

    // что отображать (контент страницы - картинка и текст)
    func swiftyOnboardPageForIndex(_ swiftyOnboard: SwiftyOnboard, index: Int) -> SwiftyOnboardPage? {
        let view = SwiftyOnboardPage()

        view.title.isHidden = true // убираем главные заголовок (не нужен)

        // изображение
        view.imageView.image = UIImage(named: "intro\(index)")

        //текст
        view.subTitle.font = UIFont(name: "Lato-Regular", size: 16)

        // какой текст отображать
        view.subTitle.text = subTitleArray[index]

        return view
    }

    // действия при нажатии на кнопки
    func swiftyOnboardViewForOverlay(_ swiftyOnboard: SwiftyOnboard) -> SwiftyOnboardOverlay? {
        let overlay = SwiftyOnboardOverlay()

        overlay.continueButton.isHidden = true

        overlay.continueButton.layer.cornerRadius = 10

        overlay.continueButton.setTitle(lsBegin, for: .normal)

        // зеленый фон
        overlay.continueButton.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        overlay.continueButton.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        overlay.continueButton.layer.shadowOpacity = 0.6
        overlay.continueButton.layer.shadowColor = UIColor.darkGray.cgColor


        //функции кнопок
        overlay.skipButton.addTarget(self, action: #selector(handleBegin), for: .touchUpInside)
        overlay.continueButton.addTarget(self, action: #selector(handleBegin), for: .touchUpInside)


        overlay.skipButton.setTitle(lsSkip, for: .normal)

        return overlay
    }

    // отображение надписей на кнопках
    func swiftyOnboardOverlayForPosition(_ swiftyOnboard: SwiftyOnboard, overlay: SwiftyOnboardOverlay, for position: Double) {


        let currentPage = round(position)
        overlay.pageControl.currentPage = Int(currentPage)


        if Int(currentPage) < pageCount-1 { // если не последняя страница
            overlay.skipButton.setTitle(lsSkip, for: .normal)
            overlay.skipButton.isHidden = false
            overlay.continueButton.isHidden = true

        } else { // если последняя страница
            overlay.skipButton.isHidden = true
            overlay.continueButton.isHidden = false
            overlay.continueButton.setTitleColor(UIColor.white, for: .normal)

        }
    }
}



