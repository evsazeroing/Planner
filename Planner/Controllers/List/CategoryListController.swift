
import UIKit

// список категорий
class CategoryListController: DictionaryController<CategoryDaoDbImpl> {

    @IBOutlet weak var tableView: UITableView! // ссылка на компонент

    // MARK: tableView

    override func viewDidLoad() {
        super.viewDidLoad()
        dictTableView = tableView
        dao = CategoryDaoDbImpl.current
        dao.getAll(sortType:CategorySortType.name)

    }



    // заполнение таблицы данными 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategory", for: indexPath) as?  CategoryListCell else{
            fatalError("fatal error with cell")
        }


        cell.selectionStyle = .none // чтобы не выделялась строка при нажатии (т.к. у нас будет включаться/выключаться иконка)


        let category = dao.items[indexPath.row] // получаем каждую категорию по индексу из массива, чтобы отобразить название

        // если категория задачи совпадает с текущей отображаемой категорией - показать зеленую иконку
        if selectedItem != nil && selectedItem == category{
            cell.buttonCheckCategory.setImage(UIImage(named: "check_green"), for: .normal)

            currentCheckedIndexPath = indexPath // сохраняем выбранный индекс

        }else{
            cell.buttonCheckCategory.setImage(UIImage(named: "check_gray"), for: .normal)
        }

        cell.labelCategoryName.text = category.name
        cell.labelCategoryName.textColor = UIColor.darkGray

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


    // методы получения списков объектов - вызываются из родительского класса

    // MARK: override
    override func getAll() -> [Category] {
        return dao.getAll(sortType: CategorySortType.name)
    }

    override func search(_ text: String) -> [Category] {
        return dao.search(text: text, sortType: CategorySortType.name)
    }



}








