
import UIKit
import ChromaColorPicker

// добавление/редактирование приоритета
class EditPriorityController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var colorPicker: ChromaColorPicker!
    @IBOutlet weak var textPriorityName: UITextField!

    var priority:Priority? // объект при редактировании

    var navigationTitle:String!

    var delegate:ActionResultDelegate!

    var priorityDAO = PriorityDaoDbImpl.current

    var selectedColor:UIColor! // выбранный цвет приоритета


    override func viewDidLoad() {
        super.viewDidLoad()

        initColorPicker()

        initTextField()

        initNavBar()

        hideKeyboardWhenTappedAround() // скрывать клавиатуру, если нажать мимо нее

        tableView.separatorStyle = .none // чтобы не было линий между ячейками

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: init

    func initTextField(){
        textPriorityName.delegate = self
        if isEmptyTrim(textPriorityName.text){
            textPriorityName.becomeFirstResponder()
        }

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // скрыть клавиатуру по нажатию на enter
        textPriorityName.resignFirstResponder()
        return true
    }

    // создать нужные кнопки в панели навигации (в зависимости от режима отображения showMode)
    func initNavBar(){
        navigationController?.setNavigationBarHidden(false, animated: true)

        // в параметрах передаем функции, которые будут вызываться по нажатию на кнопки
        createSaveCancelButtons(save: #selector(tapSave))

        self.title = navigationTitle // название меняется в зависимости от типа действий (редактирование, выбор для задачи)

    }


    // инициализация цветовой палитры
    func initColorPicker(){

        // если передали из предыдущего контроллера значение приоритета (т.е. это редактирование)
        if let priority = priority{
            textPriorityName.text = priority.name // сразу отображаем его имя

            // установить на палитре нужный цвет из приоритета
            if let color = priority.color{
                colorPicker.adjustToColor(color as! UIColor) // выбрать конкретный цвет на палитре
            }
        }

        colorPicker.hexLabel.isHidden = true // скрыть отображение HEX кода цвета
        colorPicker.supportsShadesOfGray = true // возможность выбирать черные тона
        colorPicker.padding = 10 // отступы

    }


    // MARK: IB

    @objc func tapSave() {

        if priority ==  nil{ // если создаем новый объект (не режим редактирования)
            priority = Priority(context:priorityDAO.context) // создаем пустой task

            priority?.index = Int32(priorityDAO.items.count+1) // увеличиваем индекс на 1
        }

        // передаем обратно значение priority
        if let priority = priority{

            priority.color = colorPicker.currentColor // берем текущий выбранный цвет из палитры

            if isEmptyTrim(textPriorityName.text){
                priority.name = lsNewPriority
            }else{
                priority.name = textPriorityName.text
            }

            delegate.done(source: self, data: priority) // возвращаем результат обратно в контроллер

        }

        closeController()
    }



    // MARK: tableView

    // заголовки секций
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return lsName
        case 1:
            return lsSelectColor
        default:
            return ""
        }
    }

}

