//
//  FavouritesViewController.swift
//  rub a dub
//
//  Created by Jonah Ramchandani on 29/02/2024.
//

import UIKit
import CoreLocation

class FavouritesViewController: UIViewController, CLLocationManagerDelegate, UpdatedFavouritesDelegate {
    
    @IBOutlet weak var favouritesTableView: UITableView!
    @IBOutlet weak var noFavouritesLabel: UILabel!
    
    let manager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.54822120866921, longitude: -0.0500729846566192)
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Favourites.plist")
    
    let pubBrain = PubBrain() // This is needed to run the findPubID function from within the PubBrain
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Assign delegates for location and tableview, and kickstart necessary processes
        manager.delegate = self
        manager.startUpdatingLocation()
        
        loadFavourites()
        orderByDistance()
        
        // Displaying text if the tableView is empty
        if PubBrain.favouritePubs.count != 0 {
            noFavouritesLabel.alpha = 0
        } else {
            noFavouritesLabel.alpha = 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favouritesTableView.dataSource = self
        favouritesTableView.delegate = self
        favouritesTableView.register(UINib(nibName: "ImagePubCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
                
    }

    // This is the function that actually fetches the location of the user when permitted
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 51.54822120866921, longitude: -0.0500729846566192)
        orderByDistance()
    }
    
    func orderByDistance() {
        
        //Get the distance for each pub
        if PubBrain.favouritePubs.count != 0 {
            let pubCount = PubBrain.favouritePubs.count - 1
            for index in 0...pubCount {
                let pub = PubBrain.favouritePubs[index]
                let pubCoords = CLLocation(latitude: pub.lat, longitude: pub.long)
                let location = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                let distance = location.distance(from: pubCoords)
                PubBrain.favouritePubs[index].distance = distance
            }
            
            PubBrain.favouritePubs.sort { $0.distance ?? 0.00 < $1.distance ?? 0.00 }
        }
    }
    
    func saveFavourites() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(PubBrain.favouriteIDs)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("Error encoding favourites for storage: \(error)")
        }
    }
    
    func loadFavourites() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                PubBrain.favouriteIDs = try decoder.decode([Int].self, from: data)
            } catch {
                print("Error loading favourite pubs from memory: \(error)")
            }
        }
        
        PubBrain.favouritePubs = []
        for id in PubBrain.favouriteIDs {
            if let favourite = PubBrain.pubs.first(where: { $0.id == id }) {
                PubBrain.favouritePubs.append(favourite)
            }
        }
    
        favouritesTableView.reloadData()
    }

}

extension FavouritesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PubBrain.favouritePubs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! ImagePubCell
        
        //Filling each cell with relevant information from its respective pub
        
        cell.pubName.text = PubBrain.favouritePubs[indexPath.row].name
        cell.pubImage.downloaded(from: PubBrain.favouritePubs[indexPath.row].images[0])
        cell.pubDesc.text = PubBrain.favouritePubs[indexPath.row].desc
        cell.pubOpen.text = timeBrain.checkOpen(openingTimes: PubBrain.favouritePubs[indexPath.row].openingTimes, closingTimes: PubBrain.favouritePubs[indexPath.row].closingTimes)
        if cell.pubOpen.text == "Open" {
            cell.pubOpen.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        } else if cell.pubOpen.text == "Last Orders" {
            cell.pubOpen.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        } else if cell.pubOpen.text == "Closed"  {
            cell.pubOpen.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        }
        
        //Doing the distance
        let distanceKM = ((PubBrain.favouritePubs[indexPath.row].distance ?? 1000) / 1000)
        let distanceString = String(format: "%.1f", distanceKM)
        cell.pubDistance.text = "\(distanceString)km"
        
        return cell
        
    }
}

extension FavouritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "FavouritesToPub", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PubViewController {
            destination.pub = PubBrain.favouritePubs[(favouritesTableView.indexPathForSelectedRow?.row)!]
        }
    }
    
}
