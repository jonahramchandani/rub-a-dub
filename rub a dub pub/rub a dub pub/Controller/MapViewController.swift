//
//  MapViewController.swift
//  rub a dub pub
//
//  Created by Jonah Ramchandani on 05/02/2024.
//

import CoreLocation
import UIKit
import GoogleMaps


class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, InfoWindowDelegate, FilterOverlayDelegate {
    
    @IBOutlet weak var mapArea: UIView!
    @IBOutlet weak var filterPanel: UIView!
    @IBOutlet weak var gardenButton: UIButton!
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    @IBOutlet weak var tabController: UITabBarItem!
    @IBOutlet weak var mapButton: UIButton!
    
    
    var hackneyMapView: GMSMapView?
    var timeBrain = TimeBrain()
    let manager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.54822120866921, longitude: -0.0500729846566192)
    
    let pubBrain = PubBrain()
    var pubID = ""
    var markerList: [GMSMarker] = []
    
    let pubWindow = Bundle.main.loadNibNamed("CustomInfoWindow", owner: MapViewController.self, options: nil)![0] as! CustomInfoWindow
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Using viewWillAppear so the funtion applies every time the tab is switched not just the first time the view loads, allowing the filter settings and buttons that have been pressed to carry over from one tab to the other.
        
        applyFilters()
        updateButtons()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Soften the corners to the filter buttons
        gardenButton.layer.cornerRadius = 5.0
        gardenButton.layer.masksToBounds = true
        
        foodButton.layer.cornerRadius = 5.0
        foodButton.layer.masksToBounds = true
        
        openButton.layer.cornerRadius = 5.0
        openButton.layer.masksToBounds = true
        
        otherButton.layer.cornerRadius = 5.0
        otherButton.layer.masksToBounds = true
        
        
        // Getting the tab bar to show on top of the map
        self.tabBarController?.tabBar.isHidden = false
    
        
        // The delegate for populating the Custom Info Window that appears when a marker is clicked
        pubWindow.delegate = self
        
        // Initiating all the location tracking stuff
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        // Defining the options for the mapView so that it centers on Hackney
        let options = GMSMapViewOptions()
        options.backgroundColor = #colorLiteral(red: 1, green: 0.9791241288, blue: 0.9364013076, alpha: 1)
        let zoom = 15.00
        let adjustPosition = Double(0.0075 * pow((15 / zoom), 11))
        options.camera = GMSCameraPosition.camera(withLatitude: currentLocation.latitude + adjustPosition, longitude: currentLocation.longitude - adjustPosition/1.8, zoom: 15)
        options.frame = mapArea.bounds
        
        // Initialising the mapView, setting the delegate and enabling the blue dot
        hackneyMapView = GMSMapView(options: options)
        hackneyMapView?.delegate = self
        hackneyMapView?.isMyLocationEnabled = true
        
        // Next we import the stylistic features from the "style" JSON, using a do, try
        do {
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                hackneyMapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        // Adjusting the padding so the Google logo is in the top left
        hackneyMapView?.padding = UIEdgeInsets(top: 0.0, left: 0.0, bottom: mapArea.bounds.height - 30, right: 0.0)
        
        // Finally, we overlay the map itself onto the view
        self.mapArea.addSubview(hackneyMapView!)
        
        // And pull the jump to location button back to the front
        mapArea.bringSubviewToFront(mapButton)
        
    }
    
    // This is the function that actually fetches the location of the user when permitted
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 51.54822120866921, longitude: -0.0500729846566192)
    }
    
    
    // And a didTap function that creates the selected pub's subview as a button at the bottom and adjusts the logo and map position to accomodate.
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        // #1 Highlight the marker (against the others) and recenter the map around the selected pub
        for marker in markerList {
            var iconImage = UIImage(imageLiteralResourceName: "marker")
            let iconSize = CGSize(width: 35, height: 35)
            iconImage = resizeImage(image: iconImage, targetSize: iconSize)
            marker.icon = iconImage
        }
        
        let position = marker.position
        
        var iconImagePressed = UIImage(imageLiteralResourceName: "marker pressed")
        let iconSize = CGSize(width: 35, height: 35)
        iconImagePressed = resizeImage(image: iconImagePressed, targetSize: iconSize)
        marker.icon = iconImagePressed
        let zoom = self.hackneyMapView!.camera.zoom
        
        let adjustPosition = Double(0.0075 * pow((15 / zoom), 11))
        
        let camera = GMSCameraPosition.camera(withLatitude: position.latitude + adjustPosition, longitude: position.longitude, zoom: self.hackneyMapView!.camera.zoom)
        hackneyMapView?.animate(to: camera)
        
        
        // #2 Populate the pubWindow with selected pub's information and present it at bottom of screen
        
        //First get an index to select the right pub using the marker tapped
        let id = Int(marker.title!)!
        pubID = "\(id)"
        let pubSelected = pubBrain.findPubID(pubArray: PubBrain.filteredPubs, pubID: id)!
        
        
        //Then customise the pub window accordingly
        pubWindow.pubName.text = pubSelected.name
        pubWindow.pubImage.downloaded(from: pubSelected.images[0])
        pubWindow.openLabel.text = timeBrain.checkOpen(openingTimes: pubSelected.openingTimes, closingTimes: pubSelected.closingTimes)
        if pubWindow.openLabel.text == "Open" {
            pubWindow.openLabel.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        } else if pubWindow.openLabel.text == "Last Orders" {
            pubWindow.openLabel.textColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        } else {
            pubWindow.openLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        }
        pubWindow.eventToday.text = pubSelected.calendar[timeBrain.fetchWeekDay()]
        
        
        //Get the distance in kilometers
        let pubCoords = CLLocation(latitude: pubSelected.lat, longitude: pubSelected.long)
        let location = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        var distance = location.distance(from: pubCoords)
        distance = distance / 1000
        let formattedDistance = String(format: "%.1f", distance)
        
        pubWindow.pubDistance.text = "\(formattedDistance)km"
        
        // Format the window
        let infoFrame =  CGRect(x: 10, y: 10, width: (UIScreen.main.bounds.width - 20), height: 100)
        pubWindow.frame = infoFrame
        pubWindow.frame.origin.y = mapArea.bounds.height - pubWindow.frame.height - 20
        pubWindow.alpha = 0.0
        pubWindow.layer.cornerRadius = 8.0
        pubWindow.layer.masksToBounds = true
        mapArea.addSubview(pubWindow)
        
        // Create a slight fade for it's apearance
        UIView.animate(withDuration: 0.25) {
            self.pubWindow.alpha = 1.0
        }
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        for marker in markerList {
            var iconImage = UIImage(imageLiteralResourceName: "marker")
            let iconSize = CGSize(width: 35, height: 35)
            iconImage = resizeImage(image: iconImage, targetSize: iconSize)
            marker.icon = iconImage
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.pubWindow.alpha = 0.0  // Set alpha to 0 (completely transparent)
        }) { _ in
            // Completion block - remove the subview after the animation completes
            self.pubWindow.removeFromSuperview()
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? UIImage()
    }
    
    @IBAction func mapButtonPressed(_ sender: UIButton) {
        let zoom = self.hackneyMapView!.camera.zoom
        let adjustPosition = Double(0.0075 * pow((15 / zoom), 11))
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.latitude + adjustPosition, longitude: currentLocation.longitude, zoom: zoom)
        hackneyMapView?.animate(to: camera)
    }
    
    func loadMarkers() {
        
        hackneyMapView!.clear()
        
        for pub in PubBrain.filteredPubs {
            var iconImage = UIImage(imageLiteralResourceName: "marker")
            let iconSize = CGSize(width: 35, height: 35)
            iconImage = resizeImage(image: iconImage, targetSize: iconSize)
            let pubMarker = GMSMarker()
            pubMarker.position = CLLocationCoordinate2D(latitude: pub.lat, longitude: pub.long)
            pubMarker.map = hackneyMapView
            pubMarker.title = String(pub.id)
            pubMarker.icon = iconImage
            pubMarker.infoWindowAnchor = CGPoint(x: 0.7, y: -1)
            markerList.append(pubMarker)
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
    
    @IBAction func gardenPressed(_ sender: UIButton) {
        filterChanged(filter: "garden", button: sender)
    }
    
    @IBAction func grubPressed(_ sender: UIButton) {
        filterChanged(filter: "food", button: sender)
    }
    
    @IBAction func partyPressed(_ sender: UIButton) {
        filterChanged(filter: "open", button: sender)

    }
    
    @IBAction func otherPressed(_ sender: UIButton) {
        PubBrain.filteredPubs = PubBrain.pubs
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your actual storyboard name
        if let filterOverlayVC = storyboard.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController {
            filterOverlayVC.delegate = self
            present(filterOverlayVC, animated: true, completion: nil)
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
        
        self.pubWindow.removeFromSuperview()
        loadMarkers()
    }
    
    func updateButtons() {
        
        if FilterBrain.brain["garden"] == true {
            gardenButton.setBackgroundImage(#imageLiteral(resourceName: "GVP"), for: .normal)
        } else {
            gardenButton.setBackgroundImage(#imageLiteral(resourceName: "GV"), for: .normal)
        }
        
        if FilterBrain.brain["food"] == true {
            foodButton.setBackgroundImage(#imageLiteral(resourceName: "GGP"), for: .normal)
        } else {
            foodButton.setBackgroundImage(#imageLiteral(resourceName: "GG"), for: .normal)
        }
        
        if FilterBrain.brain["open"] == true {
            openButton.setBackgroundImage(#imageLiteral(resourceName: "SOP"), for: .normal)
        } else {
            openButton.setBackgroundImage(#imageLiteral(resourceName: "SO"), for: .normal)
        }
        
        otherButton.setBackgroundImage(#imageLiteral(resourceName: "MF"), for: .normal)
        
        for (_, value) in FilterBrain.brain {
            if value == true {
                otherButton.setBackgroundImage(#imageLiteral(resourceName: "MFP"), for: .normal)
            }
        }
    }
    
    
    
    //Function to find a Pub based on the id of the marker clicked
    func findPub(withName id: String) -> Pub? {
        return PubBrain.filteredPubs.first { String($0.id) == id }
    }
    
    //Before the segue is peforemed, the pub to be shown is selected from the pub brain using the pub id found with the marker title
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapToPub" {
            if let destination = segue.destination as? PubViewController {
                
                // Ensure pubString is not empty before trying to find the Pub
                if !pubID.isEmpty, let foundPub = findPub(withName: pubID) {
                    destination.pub = foundPub
                }
            }
        }
    }
    
    
    func windowTapped() {
        performSegue(withIdentifier: "MapToPub", sender: nil)
    }
    
}

