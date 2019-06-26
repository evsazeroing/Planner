
import UIKit
import GCCalendar // обязательно надо импортировать, чтобы работать с календарем

// контроллер для выбора даты с помощью компонента GCCalendar
class DatetimePickerController: UIViewController, GCCalendarViewDelegate {

    var delegate: ActionResultDelegate! // для возврата выбранной даты

    var initDeadline:Date! // начальная дата
    var selectedDeadline:Date! // выбранная (измененная) дата

    var dateFormatter:DateFormatter!

    // MARK: outlets
    @IBOutlet weak var calendarView: GCCalendarView! // ссылка на компонент
    @IBOutlet weak var labelMonthName: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter = createDateFormatter()

        calendarView.delegate = self // обрабатываем действия календаря в этом классе
        calendarView.displayMode = .month

        // если у задачи была дата - ее нужно показать в календаре
        if initDeadline != nil{
            calendarView.select(date: initDeadline)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: GCCalendarViewDelegate

    // метод автоматически будет вызываться при изменении (выборе) даты в календаре
    func calendarView(_ calendarView: GCCalendarView, didSelectDate date: Date, inCalendar calendar: Calendar) {

        dateFormatter.dateFormat = "LLLL yyyy" // название месяца (без склонения) + год - для отображения внизу календаря, чтобы не запутаться

//        dateFormatter.calendar = calendar

        labelMonthName.text = dateFormatter.string(from: date).capitalized // формат вывода даты

        selectedDeadline = date // сохраняем выбранную дату
    }



    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */


    // MARK: actions

    @IBAction func tapCancel(_ sender: UIButton) {
        closeController()
    }


    @IBAction func tapToday(_ sender: UIButton) {
        calendarView.today()
    }

    @IBAction func tapSave(_ sender: UIButton) {
        closeController()

        delegate.done(source: self, data: selectedDeadline)

    }





}

