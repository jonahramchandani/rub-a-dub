//
//  PubViewController.swift
//  rub a dub pub
//
//  Created by Jonah Ramchandani on 30/01/2024.
//

import UIKit
import CoreLocation
import MapKit

protocol UpdatedFavouritesDelegate: FavouritesViewController {
    func saveFavourites()
}

class PubViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var closingTime: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var infoView: UIStackView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var heartButton: UIButton!
    
    @IBOutlet weak var calendarTableView: UITableView!
    @IBOutlet weak var closingTableView: UITableView!
    
    var hidden = true
    var calendar_hidden = true
    
    var pub: Pub?
    var pubImages: [String] = []
    var timeBrain = TimeBrain()
    var coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var phoneNumber: String = ""
    
    let weekdays: [String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let weekdaysShort: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var favourite = false
    weak var delegate: UpdatedFavouritesDelegate?
    let favouritesVC = FavouritesViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closingTableView.isHidden = true
        closingTableView.dataSource = self
        closingTableView.delegate = self
        closingTableView.register(UINib(nibName: "ClosingTimesCell", bundle: nil), forCellReuseIdentifier: "closingCell")
        
        calendarTableView.isHidden = true
        calendarTableView.dataSource = self
        calendarTableView.delegate = self
        calendarTableView.register(UINib(nibName: "CalendarCell", bundle: nil), forCellReuseIdentifier: "calendarCell")

        if let pub = pub {
            
            self.delegate = favouritesVC
            
            if PubBrain.favouriteIDs.contains(where: { $0 == pub.id }) {
                favourite = true
                heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }
            
            label.text = "\(pub.name)"
            descriptionLabel.text = "\(pub.desc)"
            pubImages = pub.images
            openLabel.text = timeBrain.checkOpen(openingTimes: pub.openingTimes, closingTimes: pub.closingTimes)
            if openLabel.text == "Open" {
                openLabel.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            } else if openLabel.text == "Closing Soon" {
                openLabel.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            } else if openLabel.text == "Closed" {
                openLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            }
            
            // "Closes at ..." label
            closingTime.text = "Closes at \(timeDisplyer(day: timeBrain.fetchWeekDay())) ▾"
            closingTime.isUserInteractionEnabled = true
            let closingTapped = UITapGestureRecognizer(target: self, action: #selector(closingTimesTapped))
            closingTime.addGestureRecognizer(closingTapped)
            
            
            //Doing the distance
            let distanceKM = (pub.distance ?? 1000) / 1000
            let distanceString = String(format: "%.1f", distanceKM)
            distanceLabel.text = "\(distanceString)km"
            
            coordinates = CLLocationCoordinate2D(latitude: pub.lat, longitude: pub.long)
            phoneNumber = pub.phone
            phoneButton.setTitle(phoneNumber, for: .normal)
            addressButton.setTitle(pub.address, for: .normal)
            websiteButton.setTitle(pub.website, for: .normal)
            
            calendarLabel.text = "\(weekdaysShort[timeBrain.fetchWeekDay()])  ◦  \(pub.calendar[timeBrain.fetchWeekDay()])"
            calendarLabel.isUserInteractionEnabled = true
            let calTapped = UITapGestureRecognizer(target: self, action: #selector(calendarTapped))
            calendarLabel.addGestureRecognizer(calTapped)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        imageScrollView.frame = CGRect(x: 0, y: 0, width: Int(view.frame.size.width), height: Int(image.frame.size.height))
        configureScrollView()
        
        //Adjusting the length of scroll to fit the content, plus 80 to account for margins at top and bottom of written material
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: image.frame.size.height + infoView.frame.size.height + 50)
        scrollView.frame.size.height = view.frame.size.height
        scrollView.isExclusiveTouch = false
    }
    
    private func configureScrollView() {
        imageScrollView.contentSize = CGSize(width: view.frame.size.width * CGFloat(pubImages.count), height: imageScrollView.frame.size.height)
        for x in 0..<pubImages.count {
            let page = UIImageView(frame: CGRect(x: CGFloat(x) * view.frame.size.width, y: 0, width: view.frame.size.width, height: imageScrollView.frame.size.height))
            page.contentMode = .scaleAspectFill
            page.downloaded(from: pubImages[x])
            page.clipsToBounds = true
            
            imageScrollView.addSubview(page)
        }
    }
    
    @objc func closingTimesTapped() {
        if hidden {
            UIView.animate(withDuration: 0.3) {
                self.closingTableView.isHidden = false
                self.hidden.toggle()
                self.closingTime.text = "Closes at \(self.timeDisplyer(day: self.timeBrain.fetchWeekDay()))"
            }
        } else if hidden == false {
            UIView.animate(withDuration: 0.3) {
                self.closingTableView.isHidden = true
                self.hidden.toggle()
                self.closingTime.text = "Closes at \(self.timeDisplyer(day: self.timeBrain.fetchWeekDay())) ▾"
            }
        }
    }
    
    @objc func calendarTapped() {
        if calendar_hidden {
            UIView.animate(withDuration: 0.3) {
                self.calendarTableView.isHidden = false
                self.calendar_hidden.toggle()
                self.calendarLabel.text = "What's on:"
            }
        } else if calendar_hidden == false {
            UIView.animate(withDuration: 0.3) {
                self.calendarTableView.isHidden = true
                self.calendar_hidden.toggle()
                self.calendarLabel.text = "\(self.weekdaysShort[self.timeBrain.fetchWeekDay()])  ◦  \(self.pub!.calendar[self.timeBrain.fetchWeekDay()])"
            }
        }
    }
    
    @IBAction func addressPressed(_ sender: UIButton) {
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = label.text
        mapItem.openInMaps()
    }
    
    @IBAction func phonePressed(_ sender: UIButton) {
        callNumber(phoneNumber: phoneNumber.replacingOccurrences(of: " ", with: ""))
    }
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func websitePressed(_ sender: UIButton) {
        if let url = URL(string: "https://www.\(websiteButton.titleLabel!.text!)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    @IBAction func heartPushed(_ sender: UIButton) {
        
        favourite.toggle()
        
        if let pub = pub {
            if favourite {
                sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                PubBrain.favouriteIDs.append(pub.id)
            } else {
                sender.setImage(UIImage(systemName: "heart"), for: .normal)
                PubBrain.favouriteIDs = PubBrain.favouriteIDs.filter { $0 != pub.id }
            }
        }
        
        delegate?.saveFavourites()
    }
    
    func timeDisplyer(day: Int) -> String {
        var closes = pub!.closingTimes[day]
        if closes >= 24 {
            closes = closes - 24
            if closes.truncatingRemainder(dividingBy: 1) == 0 {
                let closesInt = Int(closes)
                return "0\(closesInt):00"
            } else {
                let closesInt = Int(closes - 0.5)
                return "0\(closesInt):30"
            }
        } else {
            if closes.truncatingRemainder(dividingBy: 1) == 0 {
                let closesInt = Int(closes)
                return "\(closesInt):00"
            } else {
                let closesInt = Int(closes - 0.5)
                return "\(closesInt):30"
            }
        }
    }
}

extension PubViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == closingTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "closingCell", for: indexPath) as! ClosingTimesCell

            cell.dayLabel.text = weekdays[indexPath.row]
            
            let index: Int
            if indexPath.row == 6 {
                index = 0
            } else {
                index = indexPath.row + 1
            }
            
            cell.timeLabel.text = "\(timeDisplyer(day: index))"
            
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath) as! CalendarCell
            
            if indexPath.row == 6 {
                cell.dayLabel.text = weekdaysShort[0]
                cell.whatsOnLabel.text = pub?.calendar[0]
            } else {
                cell.dayLabel.text = weekdaysShort[indexPath.row + 1]
                cell.whatsOnLabel.text = pub?.calendar[indexPath.row + 1]
            }
            return cell

        }
    }
}

extension UIImageView {
    
    private static let imageCache = NSCache<NSString, UIImage>()
    private static let session = URLSession(configuration: .default)
    
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFill) {
        contentMode = mode
        let cacheKey = NSString(string: url.absoluteString)
        
        if let cachedImage = UIImageView.imageCache.object(forKey: cacheKey) {
            DispatchQueue.main.async { [weak self] in
                self?.image = cachedImage
            }
            return
        }
        
        UIImageView.session.dataTask(with: url) { [weak self] data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
            UIImageView.imageCache.setObject(image, forKey: cacheKey)
            
            DispatchQueue.main.async {
                self?.image = image
            }
        }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
