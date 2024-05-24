//
//  FilterViewController.swift
//  rub a dub pub
//
//  Created by Jonah Ramchandani on 30/01/2024.
//

import UIKit

protocol FilterOverlayDelegate: AnyObject {
    func applyFilters()
    func updateButtons()
}

class FilterViewController: UIViewController {
    
    weak var delegate: FilterOverlayDelegate?
    
    @IBOutlet weak var gardenFilter: UIButton!
    @IBOutlet weak var foodFilter: UIButton!
    @IBOutlet weak var openFilter: UIButton!
    @IBOutlet weak var roastFilter: UIButton!
    @IBOutlet weak var quizFilter: UIButton!
    @IBOutlet weak var sportsFilter: UIButton!
    @IBOutlet weak var cheapFilter: UIButton!
    @IBOutlet weak var beerFilter: UIButton!
    @IBOutlet weak var poolFilter: UIButton!
    @IBOutlet weak var dartsFilter: UIButton!
    @IBOutlet weak var slotsFilter: UIButton!
    @IBOutlet weak var calendarFilter: UIButton!
    @IBOutlet weak var fireFilter: UIButton!
    @IBOutlet weak var karaokeFilter: UIButton!
    @IBOutlet weak var gamesFilter: UIButton!
    @IBOutlet weak var liveFilter: UIButton!
    @IBOutlet weak var dogFilter: UIButton!
    @IBOutlet weak var jukeFilter: UIButton!
    @IBOutlet weak var functionFilter: UIButton!
    @IBOutlet weak var happyFilter: UIButton!
    
    
    @IBOutlet weak var resultsCount: UILabel!
    
    @IBOutlet weak var closingLabel: UILabel!
    @IBOutlet weak var closingSlider: UISlider!
    
    @IBOutlet weak var mondayQuiz: UIButton!
    @IBOutlet weak var tuesdayQuiz: UIButton!
    @IBOutlet weak var wednesdayQuiz: UIButton!
    @IBOutlet weak var thursdayQuiz: UIButton!
    @IBOutlet weak var fridayQuiz: UIButton!
    @IBOutlet weak var saturdayQuiz: UIButton!
    @IBOutlet weak var sundayQuiz: UIButton!
    
    @IBOutlet weak var applyButton: UIButton!
    
    var weekdayIndex: Int? = FilterBrain.weekdayIndex
    var automaticWeekday: Bool = false
    
    var weekdayButtons: [UIButton] = []
    var filterButtons: [String : UIButton] = [:]
    
    var timeBrain = TimeBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCounter()
        
        filterButtons = ["garden": self.gardenFilter, "food": self.foodFilter, "open": self.openFilter, "roast": self.roastFilter, "quiz": self.quizFilter,  "cheap": self.cheapFilter, "sports": self.sportsFilter, "beer": self.beerFilter, "pool": self.poolFilter, "darts": self.dartsFilter,  "slots": self.slotsFilter, "calendar": self.calendarFilter, "fire": self.fireFilter, "karaoke": self.karaokeFilter, "games": self.gamesFilter, "live": self.liveFilter, "dog": self.dogFilter, "juke": self.jukeFilter, "function": self.functionFilter, "happy": self.happyFilter]
        
        weekdayButtons = [self.sundayQuiz, self.mondayQuiz, self.tuesdayQuiz, self.wednesdayQuiz, self.thursdayQuiz, self.fridayQuiz, self.saturdayQuiz]
        
        for (_, button) in filterButtons {
            button.setBackgroundImage(#imageLiteral(resourceName: "GV"), for: .normal)
            button.layer.cornerRadius = 8.0
            button.layer.masksToBounds = true
        }
        
        for button in weekdayButtons {
            button.layer.cornerRadius = 5.0
            button.layer.masksToBounds = true
        }
        
        applyButton.layer.cornerRadius = 5.0
        applyButton.layer.masksToBounds = true
        
        closingSlider.minimumValue = 1
        closingSlider.maximumValue = 10
        if let closing = FilterBrain.closing {
            closingSlider.value = (2 * closing) - 44
            closingLabel.text = "Not closing before \(FilterBrain.closingString!)"
        } else {
            closingSlider.value = 1
            closingLabel.text = "No closing time selected"
        }
        
        updateButtons()
        
    }
    
    //Function to update settings on previous screen if filters page is dismissed by dragging not clicking apply
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isBeingDismissed {
            delegate?.applyFilters()
            delegate?.updateButtons()
        }
    }
    
    @IBAction func applyButtonPressed(_ sender: UIButton) {
        
        delegate?.applyFilters()
        delegate?.updateButtons()
        
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Button Toggle Functions
    
    @IBAction func gardenPressed(_ sender: UIButton) {
        filterChanged(filter: "garden", button: sender)
    }
    
    @IBAction func foodPressed(_ sender: UIButton) {
        filterChanged(filter: "food", button: sender)
    }
    
    @IBAction func openPressed(_ sender: UIButton) {
        filterChanged(filter: "open", button: sender)
    }
    
    @IBAction func roastPressed(_ sender: UIButton) {
        filterChanged(filter: "roast", button: sender)
    }
    
    @IBAction func sportsPressed(_ sender: UIButton) {
        filterChanged(filter: "sports", button: sender)
    }
    
    @IBAction func cheapPressed(_ sender: UIButton) {
        filterChanged(filter: "cheap", button: sender)
    }
    
    @IBAction func beerPressed(_ sender: UIButton) {
        filterChanged(filter: "beer", button: sender)
    }
    
    @IBAction func poolPressed(_ sender: UIButton) {
        filterChanged(filter: "pool", button: sender)
    }
    
    @IBAction func dartsPressed(_ sender: UIButton) {
        filterChanged(filter: "darts", button: sender)
    }
    
    @IBAction func slotsPressed(_ sender: UIButton) {
        filterChanged(filter: "slots", button: sender)
    }
    
    @IBAction func firePressed(_ sender: UIButton) {
        filterChanged(filter: "fire", button: sender)
    }
    
    @IBAction func karaokePressed(_ sender: UIButton) {
        filterChanged(filter: "karaoke", button: sender)
    }
    
    @IBAction func gamesPressed(_ sender: UIButton) {
        filterChanged(filter: "games", button: sender)
    }
    
    @IBAction func livePressed(_ sender: UIButton) {
        filterChanged(filter: "live", button: sender)
    }
    
    @IBAction func dogPressed(_ sender: UIButton) {
        filterChanged(filter: "dog", button: sender)
    }
    
    @IBAction func jukePressed(_ sender: UIButton) {
        filterChanged(filter: "juke", button: sender)
    }
    
    @IBAction func functionPressed(_ sender: UIButton) {
        filterChanged(filter: "function", button: sender)
    }
    
    @IBAction func quizPressed(_ sender: UIButton) {
        
        if FilterBrain.quiz == nil {
            sender.setBackgroundImage(#imageLiteral(resourceName: "Quiz P"), for: .normal)
            if let index = weekdayIndex {
                FilterBrain.brain["quiz"] = true
                FilterBrain.quiz = index
                FilterBrain.filterDictionary["quiz"] = { $0.quiz == FilterBrain.quiz }
                FilterBrain.filterArray.append("quiz")
                automaticWeekday = false
            } else {
                FilterBrain.brain["quiz"] = true
                FilterBrain.quiz = timeBrain.fetchWeekDay()
                weekdayIndex = timeBrain.fetchWeekDay()
                FilterBrain.weekdayIndex = weekdayIndex
                automaticWeekday = true
                FilterBrain.filterDictionary["quiz"] = { $0.quiz == FilterBrain.quiz }
                FilterBrain.filterArray.append("quiz")
            }
            
        } else {
            FilterBrain.brain["quiz"] = false
            FilterBrain.quiz = nil
            sender.setBackgroundImage(#imageLiteral(resourceName: "Quiz"), for: .normal)
            FilterBrain.filterDictionary.removeValue(forKey: "quiz")
            FilterBrain.filterArray = FilterBrain.filterArray.filter { $0 != "quiz" }
            if automaticWeekday {
                weekdayIndex = nil
                FilterBrain.weekdayIndex = weekdayIndex
            }
            automaticWeekday = false
        }
        
        updateButtons()
        updateCounter()
        
    }
    
    @IBAction func calendarPressed(_ sender: UIButton) {
        if FilterBrain.brain["calendar"] == false {
            sender.setBackgroundImage(#imageLiteral(resourceName: "Calendar P"), for: .normal)
            FilterBrain.brain["calendar"] = true
            if let index = weekdayIndex {
                FilterBrain.filterDictionary["calendar"] = { $0.calendar[index] != "None" }
                FilterBrain.filterArray.append("calendar")
                automaticWeekday = false
            } else {
                weekdayIndex = timeBrain.fetchWeekDay()
                FilterBrain.weekdayIndex = weekdayIndex
                automaticWeekday = true
                FilterBrain.filterDictionary["calendar"] = { $0.calendar[self.weekdayIndex!] != "None" }
                FilterBrain.filterArray.append("calendar")
            }
            
        } else {
            
            FilterBrain.brain["calendar"] = false
            sender.setBackgroundImage(#imageLiteral(resourceName: "Calendar"), for: .normal)
            FilterBrain.filterDictionary.removeValue(forKey: "calendar")
            FilterBrain.filterArray = FilterBrain.filterArray.filter { $0 != "calendar" }
            if automaticWeekday {
                weekdayIndex = nil
                FilterBrain.weekdayIndex = weekdayIndex
            }
            automaticWeekday = false
        }
        
        updateButtons()
        updateCounter()
        
    }
    
    @IBAction func happyPressed(_ sender: UIButton) {
        if FilterBrain.brain["happy"] == false {
            sender.setBackgroundImage(#imageLiteral(resourceName: "Happy P"), for: .normal)
            FilterBrain.brain["happy"] = true
            if let index = weekdayIndex {
                FilterBrain.filterDictionary["happy"] = { $0.happyHour[index] }
                FilterBrain.filterArray.append("happy")
                automaticWeekday = false
            } else {
                weekdayIndex = timeBrain.fetchWeekDay()
                FilterBrain.weekdayIndex = weekdayIndex
                automaticWeekday = true
                FilterBrain.filterDictionary["happy"] = { $0.happyHour[self.weekdayIndex!] }
                FilterBrain.filterArray.append("happy")
            }
            
        } else {
            FilterBrain.brain["happy"] = false
            sender.setBackgroundImage(#imageLiteral(resourceName: "Happy"), for: .normal)
            FilterBrain.filterDictionary.removeValue(forKey: "happy")
            FilterBrain.filterArray = FilterBrain.filterArray.filter { $0 != "happy" }
            if automaticWeekday {
                weekdayIndex = nil
                FilterBrain.weekdayIndex = weekdayIndex
            }
            automaticWeekday = false
        }
        
        updateButtons()
        updateCounter()
    }
    
    
    //MARK: - Day Buttons
    
    @IBAction func mondayPressed(_ sender: UIButton) {
        dayPressed(day: sender)
    }
    
    @IBAction func tuesdayPressed(_ sender: UIButton) {
        dayPressed(day: sender)
    }
    
    @IBAction func wednesdayPressed(_ sender: UIButton) {
        dayPressed(day: sender)
    }
    
    @IBAction func thursdayPressed(_ sender: UIButton) {
        dayPressed(day: sender)
    }
    
    @IBAction func fridayPressed(_ sender: UIButton) {
        dayPressed(day: sender)
    }
    
    @IBAction func saturdayPressed(_ sender: UIButton) {
        dayPressed(day: sender)
    }
    
    @IBAction func sundayPressed(_ sender: UIButton) {
        dayPressed(day: sender)
    }
    
    
    //MARK: - Painfully long code for picking a closing time and a pub quiz day
    
    @IBAction func sliderUpdated(_ sender: UISlider) {
        
        let roundedValue = round(sender.value)
        sender.value = roundedValue
        
        switch closingSlider.value {
        case 1:
            FilterBrain.closing = nil
            FilterBrain.closingString = nil
            closingLabel.text = "No closing time selected"
            if FilterBrain.closing != nil {
                FilterBrain.filterDictionary.removeValue(forKey: "closing")
                FilterBrain.filterArray = FilterBrain.filterArray.filter { $0 != "closing" }
            }
        case 2:
            FilterBrain.closing = 23
            FilterBrain.closingString = "11"
        case 3:
            closingLabel.text = "Not closed before 11:30"
            FilterBrain.closing = 23.5
            FilterBrain.closingString = "11:30"
        case 4:
            FilterBrain.closing = 24
            FilterBrain.closingString = "12"
        case 5:
            FilterBrain.closing = 24.5
            FilterBrain.closingString = "12:30"
        case 6:
            FilterBrain.closing = 25
            FilterBrain.closingString = "1"
        case 7:
            FilterBrain.closing = 25.5
            FilterBrain.closingString = "1:30"
        case 8:
            FilterBrain.closing = 26
            FilterBrain.closingString = "2"
        case 9:
            FilterBrain.closing = 26.5
            FilterBrain.closingString = "2:30"
        case 10:
            FilterBrain.closing = 27
            FilterBrain.closingString = "3"
        default:
            closingLabel.text = "No closing time selected"
            FilterBrain.closing = nil
            FilterBrain.closingString = nil
            if FilterBrain.closing != nil {
                FilterBrain.filterDictionary.removeValue(forKey: "closing")
                FilterBrain.filterArray = FilterBrain.filterArray.filter { $0 != "closing" }
            }
        }
        
        if let closing = FilterBrain.closing {
            if let index = weekdayIndex {
                FilterBrain.filterDictionary["closing"] = { $0.closingTimes[index] >= closing }
                FilterBrain.filterArray.append("closing")
                closingLabel.text = "Not closing before \(FilterBrain.closingString!)"
            } else {
                FilterBrain.filterDictionary["closing"] = { $0.closingTimes[self.timeBrain.fetchWeekDay()] >= closing }
                FilterBrain.filterArray.append("closing")
                closingLabel.text = "Not closing before \(FilterBrain.closingString!)"
            }
        }
        updateCounter()
    }
    
    
    //MARK: - Reusable Functions
    
    func updateButtons() {
        
        for (key, value) in FilterBrain.images {
            if FilterBrain.brain[key] == true {
                filterButtons[key]!.setBackgroundImage(#imageLiteral(resourceName: value[1]), for: .normal)
            } else {
                filterButtons[key]!.setBackgroundImage(#imageLiteral(resourceName: value[0]), for: .normal)
            }
        }
        
        if let index = weekdayIndex {
            for button in weekdayButtons {
                if index == weekdayButtons.firstIndex(of: button) {
                    button.setTitleColor(#colorLiteral(red: 0.1046482995, green: 0.2620464563, blue: 0.2818295062, alpha: 1), for: .normal)
                    button.backgroundColor = #colorLiteral(red: 1, green: 0.9836458564, blue: 0.9667497277, alpha: 1)
                }
            }
        } else {
            for button in weekdayButtons {
                button.setTitleColor(#colorLiteral(red: 1, green: 0.9836458564, blue: 0.9667497277, alpha: 1), for: .normal)
                button.backgroundColor = #colorLiteral(red: 0.1024318114, green: 0.262429893, blue: 0.281811744, alpha: 1)
            }
            
            if let closing = FilterBrain.closing {
                closingSlider.value = (2 * closing) - 44
                closingLabel.text = "Not closing before \(FilterBrain.closingString!)"
            } else {
                closingSlider.value = 1
                closingLabel.text = "No closing time selected"
            }
        }
    }
    
    func applyFilters() {
        
        if !FilterBrain.filterDictionary.isEmpty {
            PubBrain.filteredPubs = PubBrain.pubs
            for (_, value) in FilterBrain.filterDictionary {
                PubBrain.filteredPubs = PubBrain.filteredPubs.filter(value)
            }
        } else {
            PubBrain.filteredPubs = PubBrain.pubs
        }
    }
    
    func updateCounter() {
        applyFilters()
        let resultsCounter = PubBrain.filteredPubs.count
        if resultsCounter > 0 {
            resultsCount.text = "\(resultsCounter) matches for your search"
        } else {
            resultsCount.text = "Try to be less picky."
        }
    }

    func filterChanged(filter: String, button: UIButton){
        if FilterBrain.brain[filter] == false {
            FilterBrain.brain[filter] = true
            button.setBackgroundImage(#imageLiteral(resourceName: FilterBrain.images[filter]![1]), for: .normal)
            FilterBrain.filterDictionary[filter] = FilterBrain.copyDictionary[filter]
        } else {
            FilterBrain.brain[filter] = false
            button.setBackgroundImage(#imageLiteral(resourceName: FilterBrain.images[filter]![0]), for: .normal)
            FilterBrain.filterDictionary.removeValue(forKey: filter)
        }

        updateCounter()
    }
    
    func dayPressed(day: UIButton){
        if weekdayIndex == weekdayButtons.firstIndex(of: day) {
            
            weekdayIndex = nil
            FilterBrain.weekdayIndex = weekdayIndex
            day.setTitleColor(#colorLiteral(red: 1, green: 0.9836458564, blue: 0.9667497277, alpha: 1), for: .normal)
            day.backgroundColor = #colorLiteral(red: 0.1024318114, green: 0.262429893, blue: 0.281811744, alpha: 1)
            
        } else {
            
            weekdayIndex = weekdayButtons.firstIndex(of: day)
            FilterBrain.weekdayIndex = weekdayIndex
            
            for dayButton in weekdayButtons{
                if dayButton == day {
                    dayButton.setTitleColor(#colorLiteral(red: 0.1046482995, green: 0.2620464563, blue: 0.2818295062, alpha: 1), for: .normal)
                    dayButton.backgroundColor = #colorLiteral(red: 1, green: 0.9836458564, blue: 0.9667497277, alpha: 1)
                } else {
                    dayButton.setTitleColor(#colorLiteral(red: 1, green: 0.9836458564, blue: 0.9667497277, alpha: 1), for: .normal)
                    dayButton.backgroundColor = #colorLiteral(red: 0.1024318114, green: 0.262429893, blue: 0.281811744, alpha: 1)
                }
            }
        }
        
        if let weekdayIndex {
            if FilterBrain.quiz != nil {
                FilterBrain.quiz = weekdayIndex
            }
        }
        
        sliderUpdated(closingSlider)
        updateCounter()
    }
    
    @IBAction func resetPressed(_ sender: UIButton) {
        FilterBrain.filterDictionary = [:]
        PubBrain.filteredPubs = PubBrain.pubs
        weekdayIndex = nil
        FilterBrain.weekdayIndex = weekdayIndex
        for (key, _) in FilterBrain.brain {
            FilterBrain.brain[key] = false
        }
        
        FilterBrain.quiz = nil
        FilterBrain.closing = nil
        FilterBrain.closingString = nil
        closingSlider.value = 1
        closingLabel.text = "No closing time selected"
        
        updateButtons()
        updateCounter()
        applyFilters()
    }
}


