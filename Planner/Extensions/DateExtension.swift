
import Foundation

// расширение для функционала работы с датой
extension Date {

    // сегодня
    var today: Date {
        return rewindDays(0)
    }

    // получить новую дату (от текущей) путем прибавления дней
    func rewindDays (_ days:Int) -> Date{
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }


    // считает разницу между двумя датами в днях
    func offsetFrom(date: Date) -> Int {

        let cal = Calendar.current

        // чтобы правильно считать разницу между днями (без учета разницы в часах) - нужна только разница в часах
        let startOfCurrentDate = cal.startOfDay(for: date)
        let startOfOtherDay = cal.startOfDay(for: self)

        return cal.dateComponents([.day], from: startOfCurrentDate, to: startOfOtherDay).day!

    }

}

