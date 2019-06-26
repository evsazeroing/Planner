
import UIKit

// список категорий 
class CategoryListController: DictionaryController<CategoryDaoDbImpl> {

    @IBOutlet weak var tableView: UITableView! // ссылка на компонент

    @IBOutlet weak var labelHeaderTitle: UILabel!

    @IBOutlet weak var buttonSelectDeselect: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // ссылки на фактические компонента формы - для правильной работы родительского класса DictionaryController
        super.buttonSelectDeselectDict = buttonSelectDeselect
        super.tableViewDict = tableView
        super.labelHeaderTitleDict = labelHeaderTitle

        dao = CategoryDaoDbImpl.current

        initNavBar() // добавляем нужные кнопки на панель навигации

    }

    // MARK: tableView

    // заполнение таблицы данными 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategory", for: indexPath) as?  CategoryListCell else{
            fatalError("fatal error with cell")
        }

        let category = dao.items[indexPath.row] // получаем каждую категорию по индексу из массива, чтобы отобразить название

        cell.labelTaskCount.text = "\(category.tasks?.count ?? 0)" // кол-во задач для данного значения

        cell.labelCategoryName.text = category.name

        cell.selectionStyle = .none // чтобы не выделялась строка при нажатии (т.к. у нас будет включаться/выключаться иконка)

        cell.labelCategoryName.textColor = UIColor.darkGray

        if showMode == .edit{

            buttonSelectDeselect.isHidden = false


            labelHeaderTitle.text = lsCanFilter

            // все выделенные ранее категории - проставить галочки
            if category.checked{
                cell.buttonCheckCategory.setImage(UIImage(named: "check_green"), for: .normal) // меняем картинку
            }else{
                cell.buttonCheckCategory.setImage(UIImage(named: "check_gray"), for: .normal) // меняем картинку
            }
            tableView.allowsMultipleSelection = true // при фильтрации задач - можно выбирать любое кол-во категорий

            // если эта последняя запись (таблица полностью загрузилась)
            if indexPath.row == count-1{
                updateSelectDeselectButton()
            }

        // отображаем кол-во задач для данной категории (показывается только для этого режима showMode)
        }else if showMode == .select{

            tableView.allowsMultipleSelection = false

            buttonSelectDeselect.isHidden = true

            labelHeaderTitle.text = lsSelectCategory


            // если категория задачи совпадает с текущей отображаемой категорией - показать зеленую иконку
            if selectedItem != nil && selectedItem == category{
                cell.buttonCheckCategory.setImage(UIImage(named: "check_green"), for: .normal)

                currentCheckedIndexPath = indexPath // сохраняем выбранный индекс

            }else{
                cell.buttonCheckCategory.setImage(UIImage(named: "check_gray"), for: .normal)
            }

        }

        return cell

    }



    // MARK: IBActions

    @IBAction func tapSelectDeselect(_ sender: UIButton) {
        super.selectDeselectItems()
    }

    // нажатие на кнопку check для элемента списка
    @IBAction func tapCheckCategory(_ sender: UIButton) {

        // определяем индекс строки по нажатому компоненту
        let viewPosition = sender.convert(CGPoint.zero, to: tableViewDict)
        let indexPath = tableViewDict.indexPathForRow(at: viewPosition)!

        checkItem(indexPath)
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

    // действие для добавления нового элемента (метод вызывается из родительского класса, когда нажимаем на +)
    override func addItemAction() {

        // показываем диалоговое окно и реализуем замыкание, которое будет выполняться при нажатии на кнопку ОК
        showDialog(title: lsNewCategory, message: lsFillName, actionClosure: {name in

            let cat = Category(context: self.dao.context)

            if self.isEmptyTrim(name){
                cat.name = lsNewCategory
            }else{
                cat.name = name // имя получаем как параметр замыкания
            }

            self.addItem(cat)

        })


    }

    // действие для редактрование элемента
    override func editItemAction(indexPath:IndexPath) {

        // определяем какой именно объект редактируем (чтобы потом сохранять именно его)
        let currentItem = self.dao.items[indexPath.row]

        // запоминаем старое значение (чтобы потом понимать, было ли изменение и не выполнять лишних действий)
        let oldValue = currentItem.name

        // показываем диалоговое окно и реализуем замыкание, которое будет выполняться при нажатии на кнопку ОК
        showDialog(title: lsEdit, message: lsFillName, initValue: currentItem.name!, actionClosure: {name in

            if !self.isEmptyTrim(name){ //значение name из текстового поля передается в замыкание
                currentItem.name = name
            }else{
                currentItem.name = lsNewCategory
            }

            if currentItem.name != oldValue{
                //  обновляем в БД и в таблице
                self.updateItem(currentItem, indexPath: indexPath)

                self.changed = true // произошли изменения
            }else{
                self.changed = false
            }

        })

    }


   

}








