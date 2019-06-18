
import UIKit

class TaskInfoController: UIViewController {

    @IBOutlet weak var textviewTaskInfo: UITextView!

    var taskInfo:String! // текущий измененный текст

    var delegate:ActionResultDelegate! // для передачи измененного текста обратно в контроллер


    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Доп. инфо"

        // фокусируем на компоненте для открытии клавиатуры
        textviewTaskInfo.becomeFirstResponder()


        textviewTaskInfo.text = taskInfo
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func tapCancel(_ sender: UIBarButtonItem) {
        closeController()

    }

    @IBAction func tapSave(_ sender: UIBarButtonItem) {

        closeController()

        delegate?.done(source: self, data: textviewTaskInfo.text) // уведомить делегата и передать выбранное значение

    }
    
    
}
