//
//  timeBrain.swift
//  rub a dub pub
//
//  Created by Jonah Ramchandani on 01/02/2024.
//

import UIKit

struct TimeBrain {
    
    let currentDateTime = Date()
    let timeFormatter = DateFormatter()
    let dateFormatter = DateFormatter()
    
    func fetchHour() -> String {
        
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
        
        
        let timeString = timeFormatter.string(from: currentDateTime)
        let timeComponents = timeString.components(separatedBy: ":")
        
        let hourString = timeComponents[0]
        return hourString
        
    }
    
    func fetchMinute() -> String {
        
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
        
        
        let timeString = timeFormatter.string(from: currentDateTime)
        let timeComponents = timeString.components(separatedBy: ":")
        
        let minuteString = timeComponents[1]
        return minuteString
        
    }
    
    func fetchWeekDay() -> Int {
        lazy var dayIndex: Int = {
            return Calendar.current.component(.weekday, from: self.currentDateTime)
        } ()
        return dayIndex - 1
    }
    
    
    func checkOpen(openingTimes: [Float], closingTimes: [Float]) -> String {
        let closingToday = closingTimes[fetchWeekDay()]
        let openingToday = openingTimes[fetchWeekDay()]
        let currentHour = fetchHour()
        
        if var hour = Float(currentHour) {
            if hour < 9 {
                hour = hour + 24
                if hour >= openingToday {
                    if hour < (closingToday - 1) {
                        return "Open"
                    } else if hour < closingToday {
                        return "Last Orders"
                    } else {
                        return "Closed"
                    }
                } else {
                    return "Closed"
                }
            } else if hour >= openingToday {
                if hour < (closingToday - 1) {
                    return "Open"
                } else if hour < closingToday {
                    return "Last Orders"
                } else {
                    return "Closed"
                }
            } else {
                return "Closed"
            }
        } else {
            return "Closed"
        }
    }
    
    func checkOpenBool(openingTimes: [Float], closingTimes: [Float]) -> Bool {
        let closingToday = closingTimes[fetchWeekDay()]
        let openingToday = openingTimes[fetchWeekDay()]
        let currentHour = fetchHour()
        
        if var hour = Float(currentHour) {
            if hour < 9 {
                hour = hour + 24
                if hour >= openingToday {
                    if hour < (closingToday - 1) {
                        return true
                    } else if hour < closingToday {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            } else if hour >= openingToday {
                if hour < (closingToday - 1) {
                    return true
                } else if hour < closingToday {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func checkCalendar(calendar: [String]) -> Bool{
        let day = self.fetchWeekDay()
        if calendar[day] == "Just another day" {
            return false
        } else {
            return true
        }
    }
}


