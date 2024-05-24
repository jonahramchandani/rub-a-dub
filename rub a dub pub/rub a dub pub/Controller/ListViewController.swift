//
//  TabViewController.swift
//  rub a dub pub
//
//  Created by Jonah Ramchandani on 30/01/2024.
//

import UIKit
import CoreLocation

class ListViewController: UIViewController, FilterOverlayDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var pubTableView: UITableView!
    
    @IBOutlet weak var pickyLabel: UILabel!
    @IBOutlet weak var gardenButton: UIButton!
    @IBOutlet weak var grubButton: UIButton!
    @IBOutlet weak var partyButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    
    var timeBrain = TimeBrain()
    let manager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.54822120866921, longitude: -0.0500729846566192)
    
    var gradientLayer = CAGradientLayer()
    var backgroundView = UIView()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        applyFilters()
        updateButtons()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Rank pubs by how close they are to user
        orderByDistance()
        
        // Assign delegates for location and tableview, and kickstart necessary processes
        manager.delegate = self
        manager.startUpdatingLocation()
        
        pubTableView.dataSource = self
        pubTableView.delegate = self
        pubTableView.register(UINib(nibName: "ImagePubCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        pubTableView.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
        
        // Soften the corners of the buttons at the top
        gardenButton.layer.cornerRadius = 5.0
        gardenButton.layer.masksToBounds = true
        
        grubButton.layer.cornerRadius = 5.0
        grubButton.layer.masksToBounds = true
        
        partyButton.layer.cornerRadius = 5.0
        partyButton.layer.masksToBounds = true
        
        otherButton.layer.cornerRadius = 5.0
        otherButton.layer.masksToBounds = true
    }
    
    // This is the function that actually fetches the location of the user when permitted
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 51.54822120866921, longitude: -0.0500729846566192)
        orderByDistance()
    }
    
    //Function to reorder based on closeness to user
    func orderByDistance() {
        
        //Get the distance for each pub
        let pubCount = PubBrain.pubs.count - 1
        for index in 0...pubCount {
            let pub = PubBrain.pubs[index]
            let pubCoords = CLLocation(latitude: pub.lat, longitude: pub.long)
            let location = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
            let distance = location.distance(from: pubCoords)
            PubBrain.pubs[index].distance = distance
        }
        
        PubBrain.pubs.sort { $0.distance ?? 0.00 < $1.distance ?? 0.00 }
        PubBrain.filteredPubs = PubBrain.pubs
        applyFilters()
    }
    
    
    @IBAction func gardenToggled(_ sender: UIButton) {
        filterChanged(filter: "garden", button: sender)
    }
    
    @IBAction func grubToggled(_ sender: UIButton) {
        filterChanged(filter: "food", button: sender)
    }
    
    @IBAction func partyToggled(_ sender: UIButton) {
        filterChanged(filter: "open", button: sender)
    }
    
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        PubBrain.filteredPubs = PubBrain.pubs
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your actual storyboard name
        if let filterOverlayVC = storyboard.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController {
            filterOverlayVC.delegate = self
            present(filterOverlayVC, animated: true, completion: nil)
        }
    }
    
    func applyFilters() {
        
        // Update filteredPubs array based on the filter dictionary and reload it to the table view
        if !FilterBrain.filterDictionary.isEmpty {
            PubBrain.filteredPubs = PubBrain.pubs
            for (_, value) in FilterBrain.filterDictionary {
                PubBrain.filteredPubs = PubBrain.filteredPubs.filter(value)
            }
        } else {
            PubBrain.filteredPubs = PubBrain.pubs
        }
        
        // Set the tableview background to a color gradient so that when you scroll past the top or bottom the color stays the same.
        if PubBrain.filteredPubs.count < 1 {
            gradientLayer.frame = pubTableView.bounds
            gradientLayer.colors = [#colorLiteral(red: 0.1046482995, green: 0.2620464563, blue: 0.2818295062, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0.9836458564, blue: 0.9667497277, alpha: 1).cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.144)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0.145)
            backgroundView.frame = pubTableView.bounds
            backgroundView.layer.insertSublayer(gradientLayer, at: 0)
            pubTableView.backgroundView = backgroundView
            pickyLabel.alpha = 1
        } else if PubBrain.filteredPubs.count >= 1 {
            gradientLayer.frame = pubTableView.bounds
            gradientLayer.colors = [#colorLiteral(red: 0.1046482995, green: 0.2620464563, blue: 0.2818295062, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0.9836458564, blue: 0.9667497277, alpha: 1).cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.3)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0.4)
            backgroundView.frame = pubTableView.bounds
            backgroundView.layer.insertSublayer(gradientLayer, at: 0)
            pubTableView.backgroundView = backgroundView
            pickyLabel.alpha = 0
        }
        
        pubTableView.reloadData()
    }
    
    func updateButtons() {
        
        if FilterBrain.brain["garden"] == true {
            gardenButton.setBackgroundImage(#imageLiteral(resourceName: "GVP"), for: .normal)
        } else {
            gardenButton.setBackgroundImage(#imageLiteral(resourceName: "GV"), for: .normal)
        }
        
        if FilterBrain.brain["food"] == true {
            grubButton.setBackgroundImage(#imageLiteral(resourceName: "GGP"), for: .normal)
        } else {
            grubButton.setBackgroundImage(#imageLiteral(resourceName: "GG"), for: .normal)
        }
        
        if FilterBrain.brain["open"] == true {
            partyButton.setBackgroundImage(#imageLiteral(resourceName: "SOP"), for: .normal)
        } else {
            partyButton.setBackgroundImage(#imageLiteral(resourceName: "SO"), for: .normal)
        }
        
        otherButton.setBackgroundImage(#imageLiteral(resourceName: "MF"), for: .normal)

        for (_, value) in FilterBrain.brain {
            if value == true {
                otherButton.setBackgroundImage(#imageLiteral(resourceName: "MFP"), for: .normal)
            }
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
        
        applyFilters()
    }
    
}





//MARK: - Table View Delegate

extension ListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return PubBrain.filteredPubs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let titleCell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath)
            return titleCell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! ImagePubCell
            
            //Filling each cell with relevant information from its respective pub
            
            cell.pubName.text = PubBrain.filteredPubs[indexPath.row].name
            cell.pubImage.downloaded(from: PubBrain.filteredPubs[indexPath.row].images[0])
            cell.pubDesc.text = PubBrain.filteredPubs[indexPath.row].desc
            cell.pubOpen.text = timeBrain.checkOpen(openingTimes: PubBrain.filteredPubs[indexPath.row].openingTimes, closingTimes: PubBrain.filteredPubs[indexPath.row].closingTimes)
            if cell.pubOpen.text == "Open" {
                cell.pubOpen.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            } else if cell.pubOpen.text == "Last Orders" {
                cell.pubOpen.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            } else if cell.pubOpen.text == "Closed"  {
                cell.pubOpen.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            }
            
            //Doing the distance
            let distanceKM = ((PubBrain.filteredPubs[indexPath.row].distance ?? 1000) / 1000)
            let distanceString = String(format: "%.1f", distanceKM)
            cell.pubDistance.text = "\(distanceString)km"
            
            return cell
        }
    }
}

extension ListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ListToPub", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PubViewController {
            destination.pub = PubBrain.filteredPubs[(pubTableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        pubTableView.reloadData()
    }
    
}
