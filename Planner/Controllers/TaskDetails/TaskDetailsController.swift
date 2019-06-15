
import UIKit

class TaskDetailsController: UIViewController, UITableViewDataSource, UITableViewDelegate, ActionResultDelegate {

    @IBOutlet weak var tableView: UITableView! // ссылка на компонент

    // текущая задача для редактирования (либо для создания новой задачи)
    var task:Task!

    // поля для задачи (в них будут храниться последние измененные значения, в случае сохранения - эти данные запишутся в task)
    // напрямую сразу изменять поля task нельзя, т.к. возможно пользователь нажмет Отмена (а изменения уже будет не вернуть). Поэтому используем временные переменные
    var taskName:String?
    var taskInfo:String?
    var taskPriority:Priority?
    var taskCategory:Category?
    var taskDeadline:Date?

    // в какой секции какие данные будут храниться (во избежание антипаттерна magic number)
    let taskNameSection = 0
    let taskCategorySection = 1
    let taskPrioritySection = 2
    let taskDeadlineSection = 3
    let taskInfoSection = 4


    let dateFormatter = DateFormatter()

    var delegate:ActionResultDelegate! // нужен будет для уведомления и вызова функции из контроллера списка задач

    // для хранения ссылок на компоненты
    var textTaskName:UITextField!
    var textviewTaskInfo:UITextView!

    // вызывается после инициализации
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none

        // сохраняем в соотв. переменные все данные задачи
        if let task = task{ // если объект не пустой (значит режим редактирования, а не создания новой задачи)
            taskName = task.name
            taskInfo = task.info
            taskPriority = task.priority
            taskCategory = task.category
            taskDeadline = task.deadline
        }
    }

    // вызывается, если не хватает памяти (чтобы очистить ресурсы)
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                value = "Не выбрано"
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
                value = "Не выбрано"
                cell.labelTaskPriority.textColor = UIColor.lightGray
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

            var value:String

            if let deadline = taskDeadline{
                value = dateFormatter.string(from: deadline)
                cell.labelTaskDeadline.textColor = UIColor.gray
                cell.buttonClearDeadline.isHidden = false // показать
            }else{
                value = "(не указана)"
                cell.labelTaskDeadline.textColor = UIColor.lightGray
                cell.buttonClearDeadline.isHidden = true // скрыть
            }

            // заполняем компонент данными из задачи
            cell.labelTaskDeadline.text = value

            return cell

        case taskInfoSection: // доп. текстовая информация

            // получаем ссылку на ячейку
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskInfo", for: indexPath) as? TaskInfoCell else{
                fatalError("cell type")
            }

            // заполняем компонент данными из задачи
            cell.textviewTaskInfo.text = taskInfo

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
            return "Название"
        case taskCategorySection:
            return "Категория"
        case taskPrioritySection:
            return "Приоритет"
        case taskDeadlineSection:
            return "Дата"
        case taskInfoSection:
            return "Доп. информация"

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
        navigationController?.popViewController(animated: true) // контроллер удаляется из стека контроллеров
    }

    // нажали сохранить при редактировании/создании задачи
    @IBAction func tapSave(_ sender: UIBarButtonItem) {

        // присвоим изменнные значения из компонентов

        // удаляем лишние пробелы и если не пусто - присваиваем
        if let name = taskName?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty{
            task.name = name
        }else{
            task.name = "Новая задача"
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
        confirmAction(text: "Действительно хотите удалить задачу?", segueName: "DeleteTaskFromDetails")

    }


    // завершение задачи
    @IBAction func tapCompleteTask(_ sender: UIButton) {

        // подтвердить действие
        confirmAction(text: "Действительно хотите завершить задачу?", segueName: "CompleteTaskFromDetails")

    }

    func confirmAction(text:String, segueName:String){
        // объект диалогового окна
        let dialogMessage = UIAlertController(title: "Подтверждение", message: text, preferredStyle: .actionSheet)

        // создания объектов для действий (ок, отмена)

        // действие ОК
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            self.performSegue(withIdentifier: segueName, sender: self) // вызов segue по идентификатору
        })

        // действие Отмена
        let cancel = UIAlertAction(title: "Отмена", style: .cancel) { (action) -> Void in
        }

        // добавить действия в диалоговое окно
        dialogMessage.addAction(ok) // закроется диалоговое окно и вызовется segue
        dialogMessage.addAction(cancel) // просто закроется диалоговое окно

        // показать диалоговое окно
        present(dialogMessage, animated: true, completion: nil)
    }


    // MARK: prepare

    // при любом изменении текста - он будет сохраняться в переменную
    @IBAction func taskNameChanged(_ sender: UITextField) {
        taskName = sender.text
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == nil{
            return
        }

        switch segue.identifier! {
        case "SelectCategory": // переходим в контроллер для выбора категории

            if let controller = segue.destination as? CategoryListController{
                controller.selectedItem = taskCategory // передаем текущее значение категории
                controller.delegate = self
            }

        case "SelectPriority": // переходим в контроллер для выбора приоритета

            if let controller = segue.destination as?  PriorityListController{
                controller.selectedItem = taskPriority // передаем текущее значение приоритета
                controller.delegate = self

            }

        case "EditTaskInfo": // переходим в контроллер для редактирования доп. инфо

            if let controller = segue.destination as?  TaskInfoController{
                controller.taskInfo = taskInfo // передаем текущее значение приоритета
                controller.delegate = self

            }

        default:
            return
        }
    }


    // MARK: ActionResultDelegate

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

        default:
            print()
        }



    }
   
    
}

