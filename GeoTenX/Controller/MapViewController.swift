//
//  MapViewController.swift
//  sampleForGeo
//
//  Created by saadhvi on 6/13/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import RealmSwift



class PointOfInterest: NSObject {
    var address : String
    var latitude : Double
    var longitude : Double
    var done : Bool = false
    var taskTypeID: Int
    func distanceFromUser(userLoc: CLLocation) -> Double {
       return CLLocation(latitude: latitude, longitude: longitude).distance(from: userLoc)
    }
    
    
    init(address: String, latitude: Double, longitude: Double, taskTypeID: Int) {
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.taskTypeID = taskTypeID
    }
}

class MapViewController: UIViewController, CLLocationManagerDelegate, UISearchResultsUpdating, LocationUpdateProtocol {
   
    @IBOutlet weak var pointOfInterestTableView: UITableView!
    @IBOutlet weak var mapView: GMSMapView!

    @IBOutlet weak var detailButton: UIButton!
    
   // MARK: Declare variables
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var nearHundred = [PointOfInterest]()
    var filteredNearHundred = [PointOfInterest]()
    var selectedIndex : Int!
    var placesClient : GMSPlacesClient!
    var selectedPlace : GMSPlace?
    var searchController: UISearchController!
    let realm = try! Realm()
    var mapInitialized: Bool = false
    
    
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.locationUpdateNotification(_:)), name: NSNotification.Name(rawValue: kLocationDidChangeNotification), object: nil)
        let LocationMgr = LocationService.SharedManager
        LocationMgr.delegate = self
        //initLocationManager()
     
        pointOfInterestTableView.delegate = self
        pointOfInterestTableView.dataSource = self
       
        print("Current location obtained :  \(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)")
       
       // loadPOI()
       // initMap()
        
        //mapView.delegate = self
     
        //Initializing searchResultsController to nil meaning searchController will use this view controller
        //to display the results
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        
        
        pointOfInterestTableView.tableHeaderView = searchController.searchBar
        
        //sets this view controller as presenting view controller for search interface
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        //self.extendedLayoutIncludesOpaqueBars = true
    }
    
    @objc func locationUpdateNotification(_ notification: Notification) {
        let userinfo = notification.userInfo
        self.currentLocation = userinfo!["location"] as! CLLocation
        print("Latitude : \(self.currentLocation.coordinate.latitude)")
        print("Longitude : \(self.currentLocation.coordinate.longitude)")
        loadPOI()
        
        initMap()
        
    }
    
    func locationDidUpdateToLocation(location: CLLocation) {
        currentLocation = location
        print(currentLocation)
        //  initMap()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kLocationDidChangeNotification), object: nil)
    }
    func initLocationManager() {
        //Setup location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
       // locationManager.startMonitoringSignificantLocationChanges()
    }
    func initMap() {
        
            let camera = GMSCameraPosition.camera(withLatitude: (currentLocation.coordinate.latitude),longitude: (currentLocation.coordinate.longitude), zoom: 16)
            mapView.camera = camera
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            let gmsCircle = GMSCircle(position: (currentLocation.coordinate), radius: 100)
            let update = GMSCameraUpdate.fit(gmsCircle.bounds())
            mapView.animate(with: update)
        
    }
    
    func loadPOI(){
        
        let savedPlaces = Array(realm.objects(POI.self))
        nearHundred.removeAll()
        for place in savedPlaces {
            if(calcDistanceFromUser(place: place) >= 10.0) {
                let nearHundredPlace = PointOfInterest(address: place.name, latitude: place.latitude, longitude: place.longitude, taskTypeID: place.TasktypeID )
                nearHundred.append(nearHundredPlace)
                
            }
            
        }
        sortNearHundredByDistance()
        filteredNearHundred = nearHundred
        selectedIndex = nil
        self.pointOfInterestTableView.reloadData()
       
    }
    
    func sortNearHundredByDistance() {
        nearHundred.sort(by: {$0.distanceFromUser(userLoc: currentLocation) < $1.distanceFromUser(userLoc: currentLocation)})
    
    }
    
    func calcDistanceFromUser(place: POI) -> Double {
        //returns distance in meters
        let loc = CLLocation(latitude: place.latitude, longitude: place.longitude)
        let dist =  currentLocation.distance(from: loc)
        
        return dist
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Nearby Places"
        
        loadPOI()
      
    }
 
  
    @IBAction func addNewPlacePressed(_ sender: Any) {
        performSegue(withIdentifier: "addPlaceSegue", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addPlaceSegue") {
            let destinationVC = segue.destination as! AddPlaceViewController
            destinationVC.currentLocation = (currentLocation)
            
            navigationItem.title = " "
            destinationVC.navigationItem.title = "Add A New Place"
        }else if (segue.identifier == "detailSegue") {
            let destinationVC = segue.destination as! AcctDetailsViewController
            navigationItem.title = ""
            destinationVC.navigationItem.title = "Account Details"
            if(selectedIndex != nil){
                destinationVC.acctLocation = CLLocation(latitude: filteredNearHundred[selectedIndex].latitude, longitude: filteredNearHundred[selectedIndex].longitude)
                
               destinationVC.poi = filteredNearHundred[selectedIndex]
                    //print(filteredNearHundred[selectedIndex])
            }else
            {
                print("no row selected in tableview")
                //alert user to select 
            }
        //    destinationVC.navigationItem.title = "Check-In \n \(filteredNearHundred[selectedIndex].address)"
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
  
   

    @IBAction func detailBtnPressed(_ sender: Any) {
        if(selectedIndex != nil) {
            performSegue(withIdentifier: "detailSegue", sender: self)
        }else{
            //alert user if no selection made
            let alert = UIAlertController(title: "Alert", message: "Please select a place before continuing.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    
}


// MARK: TableView datasource and delegate methods
extension MapViewController : UITableViewDelegate, UITableViewDataSource {
    
    //TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("nearHundred count: \(nearHundred.count)")
        return filteredNearHundred.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointOfInterestCell", for: indexPath)

//        let item = nearHundred[indexPath.row]
//        cell.textLabel?.text = item.address
        let item = filteredNearHundred[indexPath.row]
        cell.textLabel?.text = item.address
        
        //value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = item.done == true ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
 
     
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            filteredNearHundred[indexPath.row].done = false
            selectedIndex = nil
           
            mapView.clear()
            //tableView.reloadRows(at: [indexPath], with: .top)
        }else {
            //clearing previously selected row
                for poi in filteredNearHundred{
                    poi.done = false
                }
            filteredNearHundred[indexPath.row].done = true
            selectedIndex = indexPath.row
            
            mapView.clear()
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: filteredNearHundred[indexPath.row].latitude, longitude: filteredNearHundred[indexPath.row].longitude)
            marker.map = mapView
            self.mapView.animate(toLocation: marker.position)
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filteredNearHundred = searchText.isEmpty ? nearHundred : nearHundred.filter({( poi : PointOfInterest) -> Bool in
            return poi.address.lowercased().contains(searchText.lowercased())
            })
        
            self.pointOfInterestTableView.reloadData()
        }
        
    }
    
    
    
}







