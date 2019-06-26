

import UIKit

// контроллер для настройки отображения бокового меню (таблицы с пунктами)
class SideMenuController: UITableViewController {

    @IBOutlet weak var cellFeedback: UITableViewCell!
    @IBOutlet weak var cellShare: UITableViewCell!


    // константы для секций (избегаем magic numbers)
    let commonSection = 0
    let dictionarySection = 1
    let helpSection = 2

    override func viewDidLoad() {
        super.viewDidLoad()

       
        tableView.backgroundColor = UIColor.darkGray // темный фон для меню

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: tableView

    // цвета для шапок в каждой секции
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        // стили для отображения
        let header = view as! UITableViewHeaderFooterView
        header.tintColor = UIColor.darkGray
        header.textLabel?.textColor = UIColor.lightGray
    }

    // цвета для футеров в каждой секции
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.tintColor = UIColor.darkGray

    }

    // действия при нажатии на пункты меню
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.isUserInteractionEnabled = false // защита от двойных нажатий (при новом показе контроллера значение isUserInteractionEnabled будет true)


        // "Написать разработчику"
        if tableView.cellForRow(at: indexPath) === cellFeedback{
            let email = "zhenyasalov@mail.ru" // TODO: вынести адрес в plist
            if let url = URL(string: "mailto:\(email)") {
                UIApplication.shared.open(url)
            }

            tableView.isUserInteractionEnabled = true // возвращаем возможность нажимать на таблицу (требовалось для защиты от двойных нажатий)

            return
        }


        // "Поделиться с друзьями"
        if tableView.cellForRow(at: indexPath) === cellShare{

            let shareController = UIActivityViewController(activityItems: [lsShareText], applicationActivities: nil)

            shareController.popoverPresentationController?.sourceView = self.view

            present(shareController, animated: true, completion: nil)

            tableView.isUserInteractionEnabled = true // возвращаем возможность нажимать на таблицу (требовалось для защиты от двойных нажатий)

            return
        }


    }



    // заголовки секций
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case commonSection:
            return lsMenuCommon
        case dictionarySection:
            return lsMenuDictionaries
        case helpSection:
            return lsMenuHelp
        default:
            return ""
        }
    }


    // высота секций
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    // высота футеров
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }

    // высота строк
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }



    // MARK: prepare

    // открытие нужного контроллера при нажатии на пункт меню
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == nil{
            return
        }

        switch segue.identifier! {
        case "EditCategories": // открываем контроллер для редактирования категорий
            guard let controller = segue.destination as? CategoryListController else {
                fatalError("error")
            }

            controller.showMode = .edit // режим редактирования (чтобы были доступны. доп. действия)
            controller.navigationTitle = lsEdit

        case "EditPriorities": // открываем контроллер для редактирования категорий
            guard let controller = segue.destination as? PriorityListController else {
                fatalError("error")
            }

            controller.showMode = .edit // режим редактирования (чтобы были доступны. доп. действия)
            controller.navigationTitle = lsEdit
        default:
            return
        }


    }


}
