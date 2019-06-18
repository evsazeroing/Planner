
import UIKit

class PriorityListController: DictionaryController<PriorityDaoDbImpl> {

    @IBOutlet weak var tableView: UITableView! // ссылка на компонент таблицы



    override func viewDidLoad() {
        super.viewDidLoad()
        dao = PriorityDaoDbImpl.current
        dao.getAll(sortType:PrioritySortType.index)

        dictTableView = tableView
    }


    // MARK tableView

    // заполнение таблицы данными
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellPriority", for: indexPath) as?  PriorityListCell else{
            fatalError("fatal error with cell")
        }

        cell.selectionStyle = .none // чтобы не выделялась строка при нажатии (т.к. у нас будет включаться/выключаться иконка)

        let priority = dao.items[indexPath.row] // получаем каждую приоритет по индексу из массива, чтобы отобразить название

        // если категория задачи совпадает с текущей отображаемой категорией - показать зеленую иконку
        if selectedItem != nil && selectedItem == priority{
            cell.buttonCheckPriority.setImage(UIImage(named: "check_green"), for: .normal)

            currentCheckedIndexPath = indexPath // сохраняем выбранный индекс

        }else{
            cell.buttonCheckPriority.setImage(UIImage(named: "check_gray"), for: .normal)
        }

        cell.labelPriorityName.textColor = UIColor.darkGray
        cell.labelPriorityName.text = priority.name

        return cell
    }





    // MARK: IBActions

    // нажатие на кнопку check для элемента списка
    @IBAction func tapCheckCategory(_ sender: UIButton) {
       checkItem(sender)
    }

    @IBAction func tapCancel(_ sender: UIBarButtonItem) {
        cancel()
    }

    @IBAction func tapSave(_ sender: UIBarButtonItem) {
        save()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


    // методы получения списков объектов - вызываются из родительского класса

    // MARK: override
    override func getAll() -> [Priority] {
        return dao.getAll(sortType: PrioritySortType.index)
    }

    override func search(_ text: String) -> [Priority] {
        return dao.search(text: text, sortType: PrioritySortType.index)
    }


}
