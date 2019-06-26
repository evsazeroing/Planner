

import UIKit

// контроллер для настройки отображения бокового меню (таблицы с пунктами)
class SideMenuController: UITableViewController {

    // константы для секций (избегаем magic numbers)
    let commonSection = 0
    let dictionarySection = 1
    let helpSection = 2

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

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


    // заголовки секций
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case commonSection:
            return "Общие"
        case dictionarySection:
            return "Справочники"
        case helpSection:
            return "Помощь"
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
            controller.navigationTitle = "Редактирование"

        case "EditPriorities": // открываем контроллер для редактирования категорий
            guard let controller = segue.destination as? PriorityListController else {
                fatalError("error")
            }

            controller.showMode = .edit // режим редактирования (чтобы были доступны. доп. действия)
            controller.navigationTitle = "Редактирование"
        default:
            return
        }


    }


}
