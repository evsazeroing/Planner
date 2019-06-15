
import Foundation

// доп. функции для работы задачами
extension Task {

    // считает разницу между датами (в днях)
    func daysLeft() -> Int! {

        if self.deadline == nil{
            return nil
        }

        return (self.deadline?.offsetFrom(date: Date().today))!

    }


}


