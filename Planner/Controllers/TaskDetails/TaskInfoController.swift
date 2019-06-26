
import UIKit

// контроллер для создания/редактирования доп. инфо задачи
class TaskInfoController: UIViewController {

    @IBOutlet weak var textviewTaskInfo: UITextView!

    var taskInfo:String! // текущий измененный текст

    var delegate:ActionResultDelegate! // для передачи измененного текста обратно в контроллер


    override func viewDidLoad() {
        super.viewDidLoad()

        // фокусируем на компоненте для открытии клавиатуры
        textviewTaskInfo.becomeFirstResponder()

        textviewTaskInfo.text = taskInfo
        // Do any additional setup after loading the view.




    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc func tapSave() {

        closeController()

        delegate?.done(source: self, data: textviewTaskInfo.text) // уведомить делегата и передать выбранное значение

    }



    
    
}


