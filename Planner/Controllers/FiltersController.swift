
import UIKit

// контроллер для фильтрации задачи из настроек
class FiltersController: UITableViewController {

    // номер секции, где находятся ячейки для фильтрации
    let filterSection = 0

    @IBOutlet weak var switchEmptyPriorities: UISwitch!
    @IBOutlet weak var switchEmptyCategories: UISwitch!
    @IBOutlet weak var switchEmptyDates: UISwitch!
    @IBOutlet weak var switchCompleted: UISwitch!

    // изменились ли настройки фильтрации
    var changed:Bool{
        return switchEmptyCategories.isOn != switchEmptyCategoriesInitValue ||
            switchEmptyPriorities.isOn != switchEmptyPrioritiesInitValue ||
            switchCompleted.isOn != switchCompletedInitValue ||
            switchEmptyDates.isOn != switchEmptyDatesInitValue // если хотя бы одно значение изменилось - то тогда возвратиться true
    }

    // считываем начальные значения в переменные
    var switchEmptyPrioritiesInitValue = PrefsManager.current.showEmptyPriorities
    var switchEmptyCategoriesInitValue = PrefsManager.current.showEmptyCategories
    var switchCompletedInitValue = PrefsManager.current.showCompletedTasks
    var switchEmptyDatesInitValue = PrefsManager.current.showTasksWithoutDate

    override func viewDidLoad() {
        super.viewDidLoad()

        // считываем начальное состояние переключателей
        switchEmptyCategories.isOn = switchEmptyCategoriesInitValue
        switchEmptyPriorities.isOn = switchEmptyPrioritiesInitValue
        switchCompleted.isOn = switchCompletedInitValue
        switchEmptyDates.isOn = switchEmptyDatesInitValue

        title = lsFilter
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: actions

    @IBAction func switchedWithoutPriorities(_ sender: UISwitch) {
        PrefsManager.current.showEmptyPriorities = sender.isOn // считываем значение switch (true, false)
    }
    
    
    @IBAction func switchedWithoutCategories(_ sender: UISwitch) {
        PrefsManager.current.showEmptyCategories = sender.isOn
    }


    @IBAction func switchedCompleted(_ sender: UISwitch) {
        PrefsManager.current.showCompletedTasks = sender.isOn

    }

    @IBAction func switchedWIthoutDates(_ sender: UISwitch) {
        PrefsManager.current.showTasksWithoutDate = sender.isOn
    }

    // футер для секции с фильтрацией
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == filterSection{
            return lsSelectedTasksWillShow
        }

        return ""

    }

    // заголовки секций
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == filterSection{
            return lsSelectValue
        }

        return ""
    }

    // высота секций
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    // высота футеров
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }

    // высота строк
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }


}
