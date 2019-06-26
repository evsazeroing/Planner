
import UIKit
import SwiftReorder

// список приоритетов
class PriorityListController: DictionaryController<PriorityDaoDbImpl>, ActionResultDelegate, TableViewReorderDelegate {

    @IBOutlet weak var tableView: UITableView! // ссылка на компонент таблицы

    @IBOutlet weak var labelHeaderTitle: UILabel!
    
    @IBOutlet weak var buttonSelectDeselect: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // ссылки на фактические компонента формы - для правильной работы родительского класса DictionaryController
        super.buttonSelectDeselectDict = buttonSelectDeselect
        super.tableViewDict = tableView
        super.labelHeaderTitleDict = labelHeaderTitle

        tableView.reorder.delegate = self // обработка действий по перетаскиванию элементов списка

        dao = PriorityDaoDbImpl.current

        initNavBar() // добавляем нужные кнопки на панель навигации

    }


    // MARK: tableView


    // заполнение таблицы данными
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellPriority", for: indexPath) as?  PriorityListCell else{
            fatalError("fatal error with cell")
        }

        let priority = dao.items[indexPath.row] // получаем каждую категорию по индексу из массива, чтобы отобразить название

        cell.labelPriorityName.text = priority.name

        cell.selectionStyle = .none // чтобы не выделялась строка при нажатии (т.к. у нас будет включаться/выключаться иконка)

        cell.labelPriorityName.textColor = UIColor.darkGray

        if let color = priority.color{
            cell.labelPriorityColor.backgroundColor = color as! UIColor
        }



        cell.labelTaskCount.text = "\(priority.tasks?.count ?? 0)"


        if showMode == .edit{
            
            // иконка перетаскивания
            cell.labelMoveIcon.isHidden = false
            cell.labelMoveIcon.font = UIFont.icon(from: .FontAwesome, ofSize: 17.0)
            cell.labelMoveIcon.text = String.fontAwesomeIcon("arrows")
            cell.labelMoveIcon.textColor = UIColor.lightGray

            buttonSelectDeselect.isHidden = false

            labelHeaderTitle.text = lsCanFilter

            // все выделенные ранее категории - проставить галочки
            if priority.checked{
                cell.buttonCheckPriority.setImage(UIImage(named: "check_green"), for: .normal) // меняем картинку
            }else{
                cell.buttonCheckPriority.setImage(UIImage(named: "check_gray"), for: .normal) // меняем картинку
            }
            tableView.allowsMultipleSelection = true // при фильтрации задач - можно выбирать любое кол-во категорий

            // если эта последняя запись (таблица полностью загрузилась)
            if indexPath.row == count-1{
                updateSelectDeselectButton()
            }

            // отображаем кол-во задач для данной категории (показывается только для этого режима showMode)
        }else if showMode == .select{

            cell.labelMoveIcon.isHidden = true

            tableView.allowsMultipleSelection = false

            buttonSelectDeselect.isHidden = true

            labelHeaderTitle.text = lsSelectPriority


            // если категория задачи совпадает с текущей отображаемой категорией - показать зеленую иконку
            if selectedItem != nil && selectedItem == priority{
                cell.buttonCheckPriority.setImage(UIImage(named: "check_green"), for: .normal)

                currentCheckedIndexPath = indexPath // сохраняем выбранный индекс

            }else{
                cell.buttonCheckPriority.setImage(UIImage(named: "check_gray"), for: .normal)
            }

        }

        return cell
    }





    // MARK: IBActions

    @IBAction func tapSelectDeselect(_ sender: UIButton) {
        super.selectDeselectItems()
    }
    
    // нажатие на кнопку check для элемента списка
    @IBAction func tapCheckPriority(_ sender: UIButton) {

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


    // MARK: drag

    // перетащили строку
    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath) {

        let item = dao.items.remove(at: initialSourceIndexPath.row) // удаляем со старого места
        dao.items.insert(item, at: finalDestinationIndexPath.row) // добавляем в новое место внутри коллекции

        dao.updateIndexes() // актуализиируем индексы (т.к. после перестановки они сбились)
        tableView.reloadData() // показываем обновленные данные

    }





    // можно ли передвигать строку
    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool {
        if showMode == .select || count<=1{
            return false // нельзя переставлять строки
        }

        return true
    }


    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    }


    // MARK: prepare

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditPriority" {

            guard let controller = segue.destination as? EditPriorityController else {
                fatalError("error")
            }

            controller.priority = dao.items[tableView.indexPathForSelectedRow!.row] // какой элемент в данный момент редактируем
            controller.navigationTitle = lsEdit
            controller.delegate = self

            return

        }


        if segue.identifier == "AddPriority" {

            guard let controller = segue.destination as? EditPriorityController else {
                fatalError("error")
            }

            controller.navigationTitle = lsNewPriority

            controller.delegate = self

            return

        }
    }


    // MARK: ActionResultDelegate

    func done(source: UIViewController, data: Any?) {

        if source is EditPriorityController{

            let priority = data as! Priority

            // обновление
            if let selectedIndexPath = tableView.indexPathForSelectedRow{ // определяем выбранную до этого строку (если была нажата какая-либо строка)

                updateItem(priority, indexPath: selectedIndexPath)

            }else{ // новая задача

                addItem(priority)

            }

            changed = true // произошли изменения

        }
    }


    // MARK: override

    override func addItemAction(){
        performSegue(withIdentifier: "AddPriority", sender: self)
    }

    override func editItemAction(indexPath:IndexPath){
        performSegue(withIdentifier: "EditPriority", sender: self)
    }


}
