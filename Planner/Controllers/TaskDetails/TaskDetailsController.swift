
import UIKit
import SwiftIconFont

// контроллер для редактирования/создания задачи
class TaskDetailsController: UIViewController, UITableViewDataSource, UITableViewDelegate, ActionResultDelegate {

    @IBOutlet weak var tableView: UITableView! // ссылка на компонент

    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var buttonComplete: UIButton!

    // текущая задача для редактирования (либо для создания новой задачи)
    var task:Task!

    // поля для задачи (в них будут храниться последние измененные значения, в случае сохранения - эти данные запишутся в task)
    // напрямую сразу изменять поля task нельзя, т.к. возможно пользователь нажмет Отмена (а изменения уже будет не вернуть). Поэтому используем временные переменные
    var taskName:String?
    var taskInfo:String?
    var taskPriority:Priority?
    var taskCategory:Category?
    var taskDeadline:Date?

    // в какой секции какие данные будут храниться (во избежание антипаттерна magic numbers)
    let taskNameSection = 0
    let taskCategorySection = 1
    let taskPrioritySection = 2
    let taskDeadlineSection = 3
    let taskInfoSection = 4

    var mode:TaskDetailsMode!

    var dateFormatter:DateFormatter!

    var delegate:ActionResultDelegate! // нужен будет для уведомления и вызова функции из контроллера списка задач

    // для хранения ссылок на компоненты
    var textTaskName:UITextField!
    var textviewTaskInfo:UITextView!
    var buttonDatetimePicker:UIButton!


    // вызывается после инициализации
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter = createDateFormatter()

        // сохраняем в соотв. переменные все данные задачи
        if mode == .update{ 
            taskName = task.name
            taskInfo = task.info
            taskPriority = task.priority
            taskCategory = task.category
            taskDeadline = task.deadline
        }

        hideKeyboardWhenTappedAround() // скрывать клавиатуру, если нажать мимо нее

        initButtons()

    }

    // вызывается, если не хватает памяти (чтобы очистить ресурсы)
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: init



    func initButtons(){

        // указываем иконки для кнопок (вместо текста)
        buttonDelete.titleLabel?.font = UIFont.icon(from: .FontAwesome, ofSize: 18.0)
        buttonDelete.titleLabel?.tintColor = UIColor.white
        buttonDelete.setTitle(String.fontAwesomeIcon("trash"), for: .normal)

        buttonComplete.titleLabel?.font = UIFont.icon(from: .FontAwesome, ofSize: 18.0)
        buttonComplete.titleLabel?.tintColor = UIColor.white
        buttonComplete.setTitle(String.fontAwesomeIcon("check"), for: .normal)
    }


    // MARK: tableView


    // 5 секций для отображения данных задач (по одной секции на каждое поле)
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    // в каждой секции - по одной строке
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }



    // заполняет данные задачи
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // какую секцию в данный момент заполняем
        switch indexPath.section { // имя
        case taskNameSection:

            // получаем ссылку на ячейку
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskName", for: indexPath) as? TaskNameCell else{
                fatalError("cell type")
            }

            // заполняем компонент данными из задачи
            cell.textTaskName.text = taskName

            if (cell.textTaskName.text?.isEmpty)!{ // при создании новой задачи поле пустое, поэтому переводим на него фокус (+ активируется клавиатура), чтобы пользователю не надо было отдельно нажимать на поле
                cell.textTaskName.becomeFirstResponder()
            }

            textTaskName = cell.textTaskName // чтобы можно было использовать компонент вне метода tableView и получать из него текст

            return cell


        case taskCategorySection: // категория

            // получаем ссылку на ячейку
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskCategory", for: indexPath) as? TaskCategoryCell else{
                fatalError("cell type")
            }

            // будет хранить конечный текст для отображения
            var value:String

            if let name = taskCategory?.name{
                value = name
                cell.labelTaskCategory.textColor = UIColor.darkText
            }else{
                value = lsNotSelected
                cell.labelTaskCategory.textColor = UIColor.lightGray
            }

            // заполняем компонент данными из задачи
            cell.labelTaskCategory.text = value

            return cell


        case taskPrioritySection: // приоритет

            // получаем ссылку на ячейку
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskPriority", for: indexPath) as? TaskPriorityCell else{
                fatalError("cell type")
            }


            var value:String

            if let name = taskPriority?.name{
                value = name
                cell.labelTaskPriority.textColor = UIColor.darkText
            }else{
                value = lsNotSelected
                cell.labelTaskPriority.textColor = UIColor.lightGray
            }

            // задаем цвет по приоритету
            if let priority = taskPriority{
                cell.labelTaskPriorityColor.backgroundColor = priority.color as? UIColor
            }else{
                cell.labelTaskPriorityColor.backgroundColor = UIColor.white
            }

            // заполняем компонент данными из задачи
            cell.labelTaskPriority.text = value

            return cell

        case taskDeadlineSection: // дата

            // получаем ссылку на ячейку
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskDeadline", for: indexPath) as? TaskDeadlineCell else{
                fatalError("cell type")
            }

            cell.selectionStyle = .none

            // сохраняем ссылки на компоненты, чтобы дальше в коде с ними работать
            buttonDatetimePicker = cell.buttonDatetimePicker

            var value:String

            if let deadline = taskDeadline{
                value = dateFormatter.string(from: deadline)
                cell.buttonDatetimePicker.setTitleColor(UIColor.darkText, for: .normal)
                cell.buttonClearDeadline.isHidden = false // показать
            }else{
                value = lsSelectDate
                cell.buttonDatetimePicker.setTitleColor(UIColor.lightGray, for: .normal)
                cell.buttonClearDeadline.isHidden = true // скрыть
            }

            // заполняем компонент данными из задачи
            cell.buttonDatetimePicker.setTitle(value, for: .normal)

            // текст для разницы в днях
            handleDaysDiff(taskDeadline?.offsetFrom(date: Date().today), label: cell.labelDaysDiff)

            return cell

        case taskInfoSection: // доп. текстовая информация

            // получаем ссылку на ячейку
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskInfo", for: indexPath) as? TaskInfoCell else{
                fatalError("cell type")
            }            

            // заполняем компонент данными из задачи
            if taskInfo != nil{
                cell.textviewTaskInfo.text = taskInfo
                cell.textviewTaskInfo.textColor = UIColor.darkGray
            }else{ // либо пишем подсказку
                cell.textviewTaskInfo.text = lsTapToFill
                cell.textviewTaskInfo.textColor = UIColor.lightGray
            }

            textviewTaskInfo = cell.textviewTaskInfo // чтобы можно было использовать компонент вне метода tableView и получать из него значение

            return cell

        default:
            fatalError("cell type")
        }
    }

    // названия для каждой секции
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case taskNameSection:
            return lsName
        case taskCategorySection:
            return lsCategory
        case taskPrioritySection:
            return lsPriority
        case taskDeadlineSection:
            return lsDate
        case taskInfoSection:
            return lsInfo

        default:
            return ""

        }
    }

    // высота каждой строки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.section == taskInfoSection{ // секция с доп. инфо
            return 120
        }else{
            return 45
        }
    }


    // MARK: IBActions

    // очищает дату у задачи
    @IBAction func tapClearDeadline(_ sender: UIButton) {
        taskDeadline = nil

        // обновить нужную секцию и нужную строку
        tableView.reloadRows(at: [IndexPath(row: 0, section: taskDeadlineSection)], with: .fade)
    }


    // закрытие контроллера без сохранения
    @IBAction func tapCancel(_ sender: UIBarButtonItem) {
        closeController()
    }

    // нажали сохранить при редактировании/создании задачи
    @IBAction func tapSave(_ sender: UIBarButtonItem) {

        // присвоим изменнные значения из компонентов

        task = Task(context: TaskDaoDbImpl.current.context)

        // удаляем лишние пробелы и если не пусто - присваиваем
        if !isEmptyTrim(taskName){
            task.name = taskName
        }else{
            task.name = lsNewTask
        }


        task.info = taskInfo
        task.category = taskCategory
        task.priority = taskPriority
        task.deadline = taskDeadline

        // уведомляем слушателя (делегата) о своем действии
        delegate.done(source: self, data: task)

        navigationController?.popViewController(animated: true) // контроллер удаляется из стека контроллеров   

    }



    @IBAction func tapDeleteTask(_ sender: UIButton) {

        // подтвердить действие
        confirmAction(text: lsConfirmDeleteTask) {
            self.performSegue(withIdentifier: "DeleteTaskFromDetails", sender: self) // реализация замыкания (trailing closure), которое передается как параметр
        }

    }


    // завершение задачи
    @IBAction func tapCompleteTask(_ sender: UIButton) {

        // подтвердить действие
        confirmAction(text: lsConfirmCompleteTask) {
            self.performSegue(withIdentifier: "CompleteTaskFromDetails", sender: self) // реализация замыкания (trailing closure), которое передается как параметр
        }

    }

    // нажали на выбор даты (отображение календаря)
    @IBAction func tapDatetimePicker(_ sender: UIButton) {
        // если нужно провести доп. действия при нажатии на кнопку
    }

    // при любом изменении текста - он будет сохраняться в переменную
    @IBAction func taskNameChanged(_ sender: UITextField) {
        taskName = sender.text
    }

    




    // MARK: prepare

    // выполняется перед переходом в другой контроллер
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // исключить сигвеи без идентификатора (чтобы не было ошибки в строке segue.identifier! )
        if segue.identifier == nil{
            return
        }

        // какой segue был выполнен
        switch segue.identifier! {
        case "SelectCategory": // переходим в контроллер для выбора категории

            if let controller = segue.destination as? CategoryListController{
                controller.selectedItem = taskCategory // передаем текущее значение
                controller.delegate = self // для возврата результата действий
                controller.showMode = .select // режим выбора значения
                controller.navigationTitle = lsSelectCategory
            }

        case "SelectPriority": // переходим в контроллер для выбора приоритета

            if let controller = segue.destination as?  PriorityListController{
                controller.selectedItem = taskPriority // передаем текущее значение
                controller.delegate = self // для возврата результата действий
                controller.showMode = .select // режим выбора значения
                controller.navigationTitle = lsSelectPriority
            }

        case "EditTaskInfo": // переходим в контроллер для редактирования доп. инфо

            if let controller = segue.destination as?  TaskInfoController{
                controller.taskInfo = taskInfo // передаем текущее значение
                controller.delegate = self // для возврата результата действий
                controller.navigationTitle = lsEdit
                controller.taskInfoShowMode = .edit
            }

    

        case "SelectDatetime": // переходим в контроллер для выбора даты

            if let controller = segue.destination as?  DatetimePickerController{
                controller.initDeadline = taskDeadline // передаем текущее значение
                controller.delegate = self // для возврата результата действий

            }

        default:
            return
        }
    }


    // MARK: ActionResultDelegate

    // обрабатываем действия при возврате из контроллера
    func done(source: UIViewController, data: Any?) {

        // если пришел ответ от нужного контроллера
        switch source {
        case is CategoryListController: // возвращаемся после выбора категории
            taskCategory = data as? Category

            // обновит нужную секцию и нужную строку
            tableView.reloadRows(at: [IndexPath(row: 0, section: taskCategorySection)], with: .fade)

        case is PriorityListController: // возвращаемся после выбора приоритета
            taskPriority = data as? Priority

            // обновит нужную секцию и нужную строку
            tableView.reloadRows(at: [IndexPath(row: 0, section: taskPrioritySection)], with: .fade)

        case is TaskInfoController: // возвращаемся после редактирования доп. инфо
            taskInfo = data as? String

            textviewTaskInfo.text = taskInfo



        case is DatetimePickerController: // возвращаемся после редактирования даты
            taskDeadline = data as? Date

            tableView.reloadRows(at: [IndexPath(row: 0, section: taskDeadlineSection)], with: .fade)

        default:
            print()
        }



    }

}

enum TaskDetailsMode{
    case add
    case update
}

