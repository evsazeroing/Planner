
import UIKit
import CoreData
import SideMenu
import SwiftIconFont
import Toaster

// контроллер для отображения списка задач
class TaskListController: UITableViewController, ActionResultDelegate {


    // dao
    let taskDAO = TaskDaoDbImpl.current
    let categoryDAO = CategoryDaoDbImpl.current
    let priorityDAO = PriorityDaoDbImpl.current

    var currentScopeIndex = 0 // текущая выбранная кнопка сортировки в search bar

    var searchBarActive = false

    var searchController:UISearchController! // поисковая область, который будет добавляться поверх таблицы задач


    // секции таблицы
    let quickTaskSection = 0
    let taskListSection = 1

    let sectionCount = 2 // общее кол-во секций в таблице

    var textQuickTask:UITextField! // будет хранить ссылку на текстовый компонент для создания быстрой задачи

    // для сокращения кода
    var searchBar:UISearchBar{
        return searchController.searchBar
    }


    // для сокращения кода (необязательно)
    var taskCount:Int{
        return taskDAO.items.count
    }

    var dateFormatter:DateFormatter!


    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter = createDateFormatter()

        currentScopeIndex = PrefsManager.current.sortType // сохраненный тип сортировки

        setupSearchController() // инициализаия поискового компонента

        initSlideMenu() // загрузить боковое меню

        updateTable()

        hideKeyboardWhenTappedAround() // скрывать клавиатуру, если нажать мимо нее

        initIcons()

        initContextListeners()

        title = lsTaskList

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    // MARK: core data context listeners

    // слушатели изменений контекста Core Data
    func initContextListeners(){

        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contextWillSave(_:)), name: Notification.Name.NSManagedObjectContextWillSave, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(_:)), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
    }

    @objc func contextObjectsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }

        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            print("--- INSERTS ---")
            for insert in inserts {
                print(insert.changedValues())
            }
        }

        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            print("--- UPDATES ---")
            for update in updates {
                print(update.changedValues())
            }
        }

        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            print("--- DELETES ---")
            print(deletes)
        }

    }

    @objc func contextWillSave(_ notification: Notification) {
        print(notification)
    }

    @objc func contextDidSave(_ notification: Notification) {
        print(notification)
    }




    // MARK: init

    func initSlideMenu(){
        SideMenuManager.default.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "SideMenu") as? UISideMenuNavigationController

        //        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.view)
        //        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.view)

        //        SideMenuManager.default.menuEnableSwipeGestures = false

        // чтобы не затемнялся верхний статус бар
        SideMenuManager.default.menuFadeStatusBar = false


    }

    func initIcons(){
        navigationItem.rightBarButtonItem?.icon(from: .Themify, code: "plus", ofSize: 20)
        navigationItem.leftBarButtonItem?.icon(from: .Themify, code: "menu", ofSize: 20)
    }





    // MARK: tableView

    // методы вызываются автоматически компонентом tableView

    // сколько секций нужно отображать в таблице
    override func numberOfSections(in tableView: UITableView) -> Int {

        if taskDAO.items.isEmpty{ // если нет задачи - не отображать секция для задач
            return 1
        }

        return sectionCount
    }

    // сколько будет записей в каждой секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case quickTaskSection:
            return 1 // для первой секции, где можно быстро создать новую задачу
        case taskListSection:
            // этот метод вызывается перед тем, как начать показывать строки, поэтому здесь устанавливаем нужный массив (что именно отображать)
            return taskCount // кол-во записей для отображения (столько раз будет вызываться метод tableView для отображения)
        default:
            return 0
        }

    }



    // отображение данных в строке
    // метод также вызывается автоматически компонентом TableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case quickTaskSection: // в этой секции всегда будет одна ячейка - для добавления новой задачи
            // находим компонент ячейки для отображения данных
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellQuickTask", for: indexPath) as? QuickTaskCell else{
                fatalError("fatal error with cell")
            }

            textQuickTask = cell.textQuickTask
            textQuickTask.placeholder = lsQuickTask

            return cell

        case taskListSection: // в этой секции - список задач

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTask", for: indexPath) as? TaskListCell else{
                fatalError("cell type")
            }

            let task = taskDAO.items[indexPath.row]

            cell.labelTaskName.text = task.name


            cell.labelTaskCategory.text = (task.category?.name ?? "(\(lsNoCategory))")
            cell.labelTaskCategory.textColor = UIColor.lightGray


            // задаем цвет по приоритету
            if let priority = task.priority{
                cell.labelPriority.backgroundColor = priority.color as? UIColor
            }else{
                cell.labelPriority.backgroundColor = UIColor.white
            }


            cell.labelDeadline.textColor = .lightGray

            // отображать или нет иконку блокнота
            if task.info == nil || (task.info?.isEmpty)!{
                cell.buttonTaskInfo.isHidden = true // скрыть
            }else{
                cell.buttonTaskInfo.isHidden = false // показать
            }


            // текст и стиль для отображения разницы в днях
            handleDaysDiff(task.daysLeft(), label: cell.labelDeadline)



            // стиль для завершенных задач
            if task.completed{
                cell.labelDeadline.textColor = .lightGray
                cell.labelTaskName.textColor = .lightGray
                cell.labelTaskCategory.textColor = .lightGray
                cell.labelPriority.backgroundColor = .lightGray

                cell.buttonCompleteTask.setImage(UIImage(named: "check_green"), for: .normal) // меняем картинку

                cell.selectionStyle = .none // чтобы строка не выделялась при нажатии

                cell.buttonTaskInfo.isEnabled = false

                cell.buttonTaskInfo.imageView?.image = UIImage(named: "note_gray")


            }else{ // стиль для незавершенных задач
                cell.selectionStyle = .default
                cell.buttonTaskInfo.isEnabled = true
                cell.buttonTaskInfo.imageView?.image = UIImage(named: "note")
                cell.labelTaskName.textColor = .darkGray
                cell.buttonCompleteTask.setImage(UIImage(named: "check_gray"), for: .normal) // меняем картинку
                cell.buttonTaskInfo.isEnabled = true
            }

            return cell

        default: return UITableViewCell() // пустая ячейка

        }
    }

    // установка высоты строки
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch indexPath.section {
        case quickTaskSection:
            return 40
        default:
            return 60
        }


    }

    // какие строки можно редактировать, а какие нет
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == quickTaskSection{ //  для секции 0 не даем ничего делать (т.к. там текстовое поле для быстрого создания задачи)
            return false
        }

        return true
    }

    // удаление строки
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            deleteTask(indexPath)

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    // метод отлавливает нажатие на строку
    // разрешить переход к редактированию, если задача не завершена, иначе запретить
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if taskDAO.items[indexPath.row].completed == true{ // если задача не завершена - выходим из метода
            return
        }

        // переход в контроллер для редактирования задачи
        if indexPath.section != quickTaskSection{ // чтобы не нажимали на ячейку, где быстрое создании задачи
            performSegue(withIdentifier: "UpdateTask", sender: tableView.cellForRow(at: indexPath))
        }
    }

   

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // при выполнении навигации этот метод будет выполнен автоматически
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let identificator = segue.identifier{ // если идентификатор на nil

            switch identificator { // сверяем название segue (с помощью какого segue происходит навигация)
            case "UpdateTask":

                // приведение sender к типу ячейки (получаем доступ к нажатой ячейке, чтобы определить выбранную задачу)
                let selectedCell = sender as! TaskListCell

                // выбранный индекс (номер строки, на которую нажали)
                let selectedIndex = (tableView.indexPath(for: selectedCell)?.row)!

                // выбранная задача для редактирования
                let selectedTask = taskDAO.items[selectedIndex]


                // получаем доступ к целевому контроллеру
                guard let controller = segue.destination as? TaskDetailsController else { // segue.destination - целевой контроллер
                    fatalError("error")
                }

                controller.title = lsEdit // меняем заголовок
                controller.task = selectedTask // передаем задачу в целевой контроллер
                controller.delegate = self
                controller.mode = TaskDetailsMode.update


            case "CreateTask":

                // получаем доступ к целевому контроллеру
                guard let controller = segue.destination as? TaskDetailsController else { // segue.destination - целевой контроллер
                    fatalError("error")
                }

                controller.title = lsNewTask // меняем заголовок
                controller.task = nil // объект будет создаваться только при его сохранении
                controller.delegate = self
                controller.mode = TaskDetailsMode.add

            case "ShowTaskInfo": // переходим в контроллер для просмотра доп. инфо

                // определить индекс строки таблицы для нажатой кнопки
                let button = sender as! UIButton
                let buttonPosition = button.convert(CGPoint.zero, to: self.tableView)
                let indexPath = self.tableView.indexPathForRow(at: buttonPosition)!

                // определяем задачу, для которой нажали на кнопку блокнота
                let selectedTask = taskDAO.items[indexPath.row]


                // получаем доступ к целевому контроллеру
                guard let controller = segue.destination as? TaskInfoController else { // segue.destination - целевой контроллер
                    fatalError("error")
                }

                controller.taskInfo = selectedTask.info // передаем текущее значение
//                controller.delegate = self // для возврата результата действий
                controller.navigationTitle = selectedTask.name
                controller.taskInfoShowMode = .readOnly


            default:
                return
            }
        }




    }


    // MARK: ActionResultDelegate

    // может обрабатывать ответы (слушать действия) от любых контроллеров
    func done(source: UIViewController, data: Any?) {

        // если пришел ответ от TaskDetailsController
        guard let controller = source as?  TaskDetailsController else{
            fatalError("fatal error with cell")
        }


        // сохраняет новую задачу или обновляет измененную задачу

        switch controller.mode {
        case .add:
            let task = data as! Task

            createTask(task) // создаем новую задачу
        case .update:
            let task = data as! Task

            updateTask(task) // обновляем  задачу
        default:
            return
        }


    }


    // MARK: actions


    // нажали Удалить при редактировании задачи
    @IBAction func updateTasks(segue: UIStoryboardSegue) {

        if let source = segue.source as? FiltersController, source.changed, segue.identifier == "FilterTasks" { // если были изменения в фильтрации
                updateTable()
        }

        if let source = segue.source as? CategoryListController, source.changed, segue.identifier == "UpdateTasksCategories" { // если были изменения при редактировании категорий

            updateTable()

        }

        if let source = segue.source as? PriorityListController, source.changed, segue.identifier == "UpdateTasksPriorities" { // если были изменения при редактировании приоритетов

            updateTable()

        }

    }

    // нажали Удалить при редактировании задачи
    @IBAction func deleteFromTaskDetails(segue: UIStoryboardSegue) {

        guard segue.source is TaskDetailsController else { // принимаем вызовы только от TaskDetailsController (для более строгого кода)
            fatalError("return from unknown source")
        }

        // проверяем идентификатор, что именно от этого segue
        if segue.identifier == "DeleteTaskFromDetails", let selectedIndexPath = tableView.indexPathForSelectedRow{ // tableView.indexPathForSelectedRow - индекс последней нажатой строки

            deleteTask(selectedIndexPath)

        }

    }

    // нажали Завершить при редактировании задачи
    @IBAction func completeFromTaskDetails(segue: UIStoryboardSegue) {

        if let selectedIndexPath = tableView.indexPathForSelectedRow{  // индекс последней нажатой строки
            completeTask(selectedIndexPath)
        }
    }

    @IBAction func tapCompleteTask(_ sender: UIButton) {

        // определяем индекс строки по нажатому компоненту
        let viewPosition = sender.convert(CGPoint.zero, to: tableView)
        let indexPath = self.tableView.indexPathForRow(at: viewPosition)!

        completeTask(indexPath)

    }

    @IBAction func tapCreateTask(_ sender: UIBarButtonItem) {

        // переход в контроллер для создания задачи
        performSegue(withIdentifier: "CreateTask", sender: tableView)

    }



    @IBAction func quickTaskAdd(_ sender: UITextField) {


        // если пусто - ничего не делаем
        if isEmptyTrim(textQuickTask.text){
            return
        }

        let task = Task(context:taskDAO.context)

        task.name = textQuickTask.text

        createTask(task)

        textQuickTask.text = ""
        
    }


    // MARK: dao

    // удалить задачу
    func deleteTask(_ indexPath:IndexPath){

        let task = taskDAO.items[indexPath.row]
        taskDAO.delete(task) // удалить задачу из БД
        taskDAO.items.remove(at: indexPath.row) // удалить саму строку и объект из коллекции (массива)

        if taskDAO.items.isEmpty{ // если это последняя запись - удаляем всю секцию, иначе будет ошибка при попытке отображения таблицы
            tableView.deleteSections( IndexSet([taskListSection]), with: .left)
        }else{
            tableView.deleteRows(at: [indexPath], with: .left)
        }

        updateTableBackground(tableView, count: taskCount)
    }

    // завершить задачу
    func completeTask(_ indexPath:IndexPath){

        // обновляем вид строки
        let task = taskDAO.items[indexPath.row]

        task.completed = !task.completed // меняем состояние задачи на противоположное

        taskDAO.update(task)

        tableView.reloadRows(at: [indexPath], with: .fade) // сделать строку серой (вызовется метод tableView, который заново заполнит нажатую строку)


        // показать анимацию ухода строки с задержкой
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) { // если пользователь будет быстро нажимать на разные завершения задач - все будет выполняться параллельно

            if !PrefsManager.current.showCompletedTasks{ // если отключен показ завершенных задач - только тогда выполнять анимацию (иначе строка просто останеся серой и не исчезнет)

                // ВАЖНО! нужно одновременно удалять задачу из коллекции и из таблицы, чтобы было синхронизировано

                //  удалить задачу из коллекции и таблицы
                self.taskDAO.items.remove(at: indexPath.row)

                if self.taskDAO.items.isEmpty{ // если это последняя запись - удаляем всю секцию, иначе будет ошибка при попытке отображения таблицы
                    self.tableView.deleteSections( IndexSet([self.taskListSection]), with: .top)
                }else{
                    self.tableView.deleteRows(at: [indexPath], with: .top)
                }

                self.updateTableBackground(self.tableView, count:self.taskCount)

            }
        }


    }

    // добавить новую задачу
    func createTask(_ task:Task){
        taskDAO.add(task)

        attemptUpdate(task, forceUpdate: false, text: lsTaskAddedButNotShow)

    }

    // обновить задачу
    func updateTask(_ task:Task){
        taskDAO.update(task)

        attemptUpdate(task, forceUpdate: true, text: lsTaskUpdatedButNotShow)

    }

    // нужно обновлять таблицу или нет
    // Если новая/отредактированная задача не подпадает в текущий список (из-за фильтрации, поиска и пр.) - уведомить об этом пользователя (чтобы не паниковал, куда девалась  задача)
    // прогоняем через все условия фильтра (можно было реализовать по-простому с помощью  items.contains - но если массив будет большим - возможны "подвисания")
    func attemptUpdate(_ task:Task, forceUpdate:Bool, text:String){ // forceUpdate - если в любом случае нужно обновить

        var willShow = true // задача будет отображаться в текущем списке

        var text = text // чтобы можно было изменять текст (т.к. параметр функции - константа)


        // чтобы не зависал UI - выполняем асинхронно
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {

            // если НЕ показываем заверешенные задачи, а у задачи статус "завершен"
            if !PrefsManager.current.showCompletedTasks && task.completed == true{
                willShow = false
            }

            else

                // если НЕ показываем задачи без категории, а у задачи пустая категория
                if !PrefsManager.current.showEmptyCategories && task.category == nil{
                    willShow = false
                    text = text + "\"\(lsNotShowEmptyCategories)\""
                }

                else

                    // если НЕ показываем задачи без приоритета, а у задачи пустой приоритет
                    if !PrefsManager.current.showEmptyPriorities && task.priority == nil{
                        willShow = false
                        text = text + "\"\(lsNotShowEmptyPriorities)\""
                    }

                    else

                        // если НЕ показываем задачи без даты, а у задачи пустая дата
                        if !PrefsManager.current.showTasksWithoutDate && task.deadline == nil{
                            willShow = false
                            text = text + "\"\(lsNotShowWithoutDate)\""
                        }


                        else

                            // если не проходит по фильтрации категорий
                            if let category = task.category, !self.categoryDAO.checkedItems().contains(category){
                                willShow = false
                                text = text + "\"\(lsNotShowCategory)\""
                            }

                            else

                                // если не проходит по фильтрации приоритетов
                                if let priority = task.priority, !self.priorityDAO.checkedItems().contains(priority){
                                    willShow = false
                                    text = text + "\"\(lsNotShowPriority)\""

                                }


                                else

                                    // если открыт поиск, а имя задачи не содержит текст поиска
                                    if (self.searchBarActive && task.name?.lowercased().range(of:self.searchBar.text!.lowercased()) == nil) {
                                        willShow = false
                                        text = text + "\(lsNameNotContains) "+"\'\(self.searchBar.text!)\'"



            }

            if willShow { // если задача должна показываться - обновляем таблицу
                self.updateTable()
            }else{

                if forceUpdate{ // если все равно надо обновить
                    self.updateTable()
                }

                // уведомить пользователя о том, что задача не будет отображаться в текущем списке из-за фильтров
                Toast(text: text, delay: 0, duration: Delay.long).show()

            }




        }

    }


    // MARK update table

    // обновить все данные в таблице (с учетом поиска, сортировки и пр.)
    func updateTable(){

        let sortType = TaskSortType(rawValue: currentScopeIndex)! // определяем тип сортировки по текущему выбранному значение scope button из search bar

        // если активен режим поиска (search bar) и текст не пустой
        if searchBarActive && !isEmptyTrim(searchBar.text) {

            // найти все задачи с выбранными фильтрами, категориями, сортировкой (c поиском по тексту)
            taskDAO.search(text: searchBar.text!, categories: categoryDAO.checkedItems(), priorities: priorityDAO.checkedItems(), sortType: sortType, showTasksEmptyCategories:PrefsManager.current.showEmptyCategories, showTasksEmptyPriorities: PrefsManager.current.showEmptyPriorities, showCompletedTasks: PrefsManager.current.showCompletedTasks, showTasksWithoutDate: PrefsManager.current.showTasksWithoutDate)

        }else{ // найти все задачи с выбранными фильтрами, категориями, сортировкой (без поиска по тексту)
             taskDAO.search(text: nil, categories: categoryDAO.checkedItems(), priorities: priorityDAO.checkedItems(), sortType: sortType, showTasksEmptyCategories:PrefsManager.current.showEmptyCategories, showTasksEmptyPriorities: PrefsManager.current.showEmptyPriorities, showCompletedTasks: PrefsManager.current.showCompletedTasks, showTasksWithoutDate: PrefsManager.current.showTasksWithoutDate)
        }

        tableView.reloadData() // обновить таблицу

        updateTableBackground(tableView, count:taskCount)


    }






}


// настройка searchController и обработка действия при поиске
// можно удалить, добавил для наглядности
extension TaskListController : UISearchResultsUpdating {

    // метод делегата - вызывается автоматически для каждой буквы поиска (или когда пользователь просто активирует поиск, еще не введя текст)
    func updateSearchResults(for searchController: UISearchController) {

        // не будем использовать этот метод для поиска, т.к. нам не нужно искать после каждой нажатой буквы (для больших объемов данных может подвисать)
        // будем искать только после нажатия на enter


    }

}


// обработка действия при поиске
extension TaskListController : UISearchBarDelegate {

    // добавление search bar к таблице
    func setupSearchController() {

        searchController = UISearchController(searchResultsController: nil) // searchResultsController: nil - т.к. результаты будут сразу отображаться в этом же view

        searchController.dimsBackgroundDuringPresentation = false // затемнять фон или нет, при поиске (при затменении - не будет доступно выбирать найденную запись)
        // строка поиска будет показываться только для списка (не будет переходить в другой контроллер)

        // для правильного отображения внутри таблицы, подробнее http://www.thomasdenney.co.uk/blog/2014/10/5/uisearchcontroller-and-definespresentationcontext/
        definesPresentationContext = true

        searchBar.placeholder = lsSearchByName
        searchBar.backgroundColor = .white

        searchBar.scopeButtonTitles = [lsAZ, lsPriority, lsDate] // добавляем scope buttons
        searchBar.selectedScopeButtonIndex = currentScopeIndex // выделяем выбранную кнопку



        // обработка действий поиска и работа с search bar - в этом же классе (без этих 2 строк не будет работать поиск)
//        searchController.searchResultsUpdater = self // т.к. не используем
        searchBar.delegate = self

        // сразу не показывать segmented controls для сортировки результата (такой подход связан с глюком, когда компоненты налезают друг на друга)
        searchBar.showsScopeBar = false



        // из-за бага в работе searchController - применяем разные способы добавления searchBar в зависимости от версии iOS
        if #available(iOS 11.0, *) { // если версия iOS от 11 и выше
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchBar
        }


    }


    // MARK: search delegate


    // обязываем пользователя нажимать enter для поиска (чтобы не искать после каждой введенной буквы - может подвисвать для больших объемов данных)
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }

    // начали редактировать текст поиска
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBarActive = true // есть также метод searchBar.isActive - но значение в него может быть записано позднее, чем это нужно нам, поэтому используем ручной способ - как только пользователь нажал на строку поиска - сохраняем true в переменную searchBarActive
    }

    // закончили редактировать текст поиска (нажали на Search)
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

        if !isEmptyTrim(searchBar.text){
            updateTable()
        }
    }

    // нажимаем на кнопку Cancel
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        // при первом открытии и закрытии поиска на форме - активировать scope buttons (такой подход связан с глюком, когда компоненты налезают друг на друга при нажатии на Отмену)
        if !searchBar.showsScopeBar{
            searchBar.showsScopeBar = true
        }

        searchBarActive = false
        searchBar.text = ""

        updateTable() // обновить список задач согласно тексту поиска (если есть), сортировке и пр.

    }


    // переключение между кнопками сортировки (кнопки могут называть по разному: segmented controls, scope buttons)
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {

        if currentScopeIndex == selectedScope{ // если значение не изменилось (нажали уже активную кнопку) - ничего не делаем
            return
        }

        currentScopeIndex = selectedScope // сохраняем выбранный scope button (способ сортировки списка задач)

        PrefsManager.current.sortType = currentScopeIndex // сохраняем в настройки приложения


        updateTable() // обновить список задач согласно тексту поиска (если есть), сортировке и пр.

    }

}




