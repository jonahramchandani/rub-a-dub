import UIKit

let currentDateTime = Date()

func fetchWeekDay() -> Int {
    lazy var dayIndex: Int = {
        return Calendar.current.component(.weekday, from: currentDateTime)
    } ()
    print(dayIndex - 2)
    return dayIndex - 2
}

fetchWeekDay()
