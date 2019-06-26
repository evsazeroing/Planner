
import UIKit

// контроллер для создания/редактирования/просмотра доп. инфо задачи
class TaskInfoController: UIViewController {

    // в настройках IB для компонента нужно поставить автоопределение ссылок
    @IBOutlet weak var textviewTaskInfo: UITextView!

    var taskInfo:String! // текущий измененный текст

    var delegate:ActionResultDelegate! // для передачи измененного текста обратно в контроллер

    var taskInfoShowMode:TaskInfoShowMode!

    var navigationTitle:String!


    override func viewDidLoad() {
        super.viewDidLoad()



        title = navigationTitle

        textviewTaskInfo.text = taskInfo
        // Do any additional setup after loading the view.

        switch taskInfoShowMode {
        case .readOnly:
            textviewTaskInfo.isEditable = false
            
            // добавляем возможность обрабатывать нажатие на текстовое поле
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: textviewTaskInfo, action:    #selector(tapTextView(_:))) // передается ссылка на созданный UITapGestureRecognizer, чтобы далее определить, в каком месте нажали
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)


        case .edit:

            textviewTaskInfo.isEditable = true
            createSaveCancelButtons(save: #selector(tapSave))
            textviewTaskInfo.becomeFirstResponder() // сразу даем редактировать и показываем клавиатуру

        default:
            return
        }



    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc func tapSave() {

        closeController()

        delegate?.done(source: self, data: textviewTaskInfo.text) // уведомить делегата и передать выбранное значение

    }


    @objc func tapTextView(_ sender: UITapGestureRecognizer){
        textviewTaskInfo.findUrl(sender: sender) // ищет url при нажатии на текстовый компонента
    }
    
    
}

// режимы работы
enum TaskInfoShowMode{
    case readOnly // добавление, редактирование
    case edit // выбор значения для задачи
}

