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
    var name: String
    var address : String
    var latitude : Double
    var longitude : Double
    var done : Bool = false
    var AccountTypeID: Int
    var createdDate: String
   
    var acctDescription: String
    var status: String
    func distanceFromUser(userLoc: CLLocation) -> Double {
       return CLLocation(latitude: latitude, longitude: longitude).distance(from: userLoc)
    }
    
    
    init(name: String, address: String, latitude: Double, longitude: Double, accountTypeID: Int, createdDate: String, accountDescription: String, status: String) {
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.AccountTypeID = accountTypeID
        self.name = name
        self.createdDate = createdDate
        self.acctDescription = accountDescription
        self.status = status
    }
}

class MapViewController: UIViewController, CLLocationManagerDelegate, UISearchResultsUpdating, LocationUpdateProtocol {
   
    @IBOutlet weak var pointOfInterestTableView: UITableView!
    @IBOutlet weak var mapView: GMSMapView!

    @IBOutlet weak var detailButton: UIButton!
    
    @IBOutlet weak var taskButton: UIButton!
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
    var savedPlaces = [POI]()
    var copysavedPlaces = [POI]()
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        detailButton.setTitle(NSLocalizedString("Account Details", comment: "View Account Details"), for: .normal)
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
        print("Latitude from mapviewcontroller: \(self.currentLocation.coordinate.latitude)")
        print("Longitude from mapviewcontroller : \(self.currentLocation.coordinate.longitude)")
        
        
        initMap()
        loadPOI()
        
    }
    
    func locationDidUpdateToLocation(location: CLLocation) {
        currentLocation = location
        print(currentLocation)
        //  initMap()
    }
    override func viewWillDisappear(_ animated: Bool) {
        
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kLocationDidChangeNotification), object: nil)
        do{
            try realm.write {
                for place in savedPlaces{
                    place.done = false
                }
            }
        
        
       
        }catch{
            print("error updating done field in POI")
        }
    }
    func initLocationManager() {
        //Setup location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
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
        savedPlaces = Array(realm.objects(POI.self))
        copysavedPlaces = savedPlaces
        sortPlacesByDist()
        selectedIndex = nil
        self.pointOfInterestTableView.reloadData()
    }
    func sortPlacesByDist(){
    savedPlaces.sort(by: {$0.distanceFromUser(userLoc: currentLocation) < $1.distanceFromUser(userLoc: currentLocation)})
    }
    func loadNearHundredPOI(){
        
        let savedPlaces = Array(realm.objects(POI.self))
        nearHundred.removeAll()
        for place in savedPlaces {
            if(calcDistanceFromUser(place: place) <= 100) {
             
                let nearHundredPlace = PointOfInterest(name: place.name, address: place.address, latitude: place.latitude, longitude: place.longitude, accountTypeID: place.AccountTypeID, createdDate: place.createdDate, accountDescription: place.AccountDescription, status: place.status)
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
        detailButton.isUserInteractionEnabled = true
        taskButton.isUserInteractionEnabled = true
        navigationItem.title = NSLocalizedString("Nearby Places", comment: "Places near you")
        
        loadPOI()
      
    }
 
  
    @IBAction func addNewPlacePressed(_ sender: Any) {
      //  (sender as! UIButton).isEnabled = false
       // performSegue(withIdentifier: "addPlaceSegue", sender: self)
       performSegue(withIdentifier: "acctTypesSegue", sender: self)
    }
    
   
    @IBAction func taskBtnPressed(_ sender: Any) {
        if(selectedIndex != nil) {
            taskButton.isUserInteractionEnabled = false
            UnSyncedTaskByAccount.SharedInstance.getUnsyncedTask(id:savedPlaces[selectedIndex].accountID) {
                (result) in
                print("got back:\(result)")
                DispatchQueue.main.async {
                     self.performSegue(withIdentifier: "taskTypesSegue", sender: self)
                }
            }
           
        }else{
            //alert user if no selection made
            let formatString = NSLocalizedString("Please select a place before continuing.", comment: "Select a place to continue")
            let alert = UIAlertController(title: "Alert", message: formatString, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
       
    }
    
  /*  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addPlaceSegue") {
            let destinationVC = segue.destination as! AddPlaceViewController
            destinationVC.currentLocation = (currentLocation)
            
            navigationItem.title = " "
            destinationVC.navigationItem.title = NSLocalizedString("Add A New Place", comment: "Add A New Place")
        }else if (segue.identifier == "detailSegue") {
            let destinationVC = segue.destination as! AcctDetailsViewController
            navigationItem.title = ""
            destinationVC.navigationItem.title = NSLocalizedString("Account Details", comment: "Account Details")
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
    }*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if(segue.identifier == "acctTypesSegue") {
            let destinationVC = segue.destination as! AcctTypesViewController
            destinationVC.currentLocation = (currentLocation)
     //       destinationVC.acctTypeID = savedPlaces[selectedIndex].AccountTypeID
            navigationItem.title = " "
            destinationVC.navigationItem.title = NSLocalizedString("Account Types", comment: "Account Types")
        }else
        if (segue.identifier == "detailSegue") {
            let destinationVC = segue.destination as! AcctDetailsViewController
            navigationItem.title = ""
            destinationVC.navigationItem.title = NSLocalizedString("Account Details", comment: "Account Details")
            if(selectedIndex != nil){
                destinationVC.acctLocation = CLLocation(latitude: savedPlaces[selectedIndex].latitude, longitude: savedPlaces[selectedIndex].longitude)
                destinationVC.currentLocation = currentLocation
                destinationVC.poi = savedPlaces[selectedIndex]
                //print(filteredNearHundred[selectedIndex])
            }
        }else
                 if (segue.identifier == "taskTypesSegue") {
                    let destinationVC = segue.destination as! TaskTypesViewController
                    navigationItem.title = ""
                    destinationVC.navigationItem.title = NSLocalizedString("Task Types", comment: "Task Types")
                    
                    destinationVC.poi = savedPlaces[selectedIndex]
                    destinationVC.currentLocation = currentLocation
                    
            }else
            {
                print("no row selected in tableview")
                //alert user to select
            }
            //    destinationVC.navigationItem.title = "Check-In \n \(filteredNearHundred[selectedIndex].address)"
        }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
  
   

    @IBAction func detailBtnPressed(_ sender: Any) {
        if(selectedIndex != nil) {
            detailButton.isUserInteractionEnabled = false
            UnSyncedTaskByAccount.SharedInstance.getUnsyncedTask(id:savedPlaces[selectedIndex].accountID) {
                (result) in
                print("got back:\(result)")
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "detailSegue", sender: self)
                }
            }
            
            
            
        }else{
            //alert user if no selection made
            let formatString = NSLocalizedString("Please select a place before continuing.", comment: "Select a place to continue")
            let alert = UIAlertController(title: "Alert", message: formatString, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    
}


// MARK: TableView datasource and delegate methods
extension MapViewController : UITableViewDelegate, UITableViewDataSource {
//TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("savedPlaces count: \(savedPlaces.count)")
        return savedPlaces.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointOfInterestCell", for: indexPath)
      
        let item = savedPlaces[indexPath.row]
        cell.textLabel?.text = item.name
        
        //value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = item.done == true ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    do{
        try realm.write{
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            savedPlaces[indexPath.row].done = false
            selectedIndex = nil
            
            mapView.clear()
            //tableView.reloadRows(at: [indexPath], with: .top)
        }else {
            //clearing previously selected row
            for poi in savedPlaces{
                poi.done = false
            }
            savedPlaces[indexPath.row].done = true
            
            selectedIndex = indexPath.row
            
            mapView.clear()
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: savedPlaces[indexPath.row].latitude, longitude: savedPlaces[indexPath.row].longitude)
            marker.map = mapView
            self.mapView.animate(toLocation: marker.position)
          }
        }
    }catch{
        print("error selecting tableview row")
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text {
            
            savedPlaces = searchText.isEmpty ? copysavedPlaces : copysavedPlaces.filter({( poi : POI) -> Bool in
                return poi.name.lowercased().contains(searchText.lowercased())
            })
           self.pointOfInterestTableView.reloadData()
            
        }
        self.pointOfInterestTableView.reloadData()
    }
    //TableView DataSource Methods
 /*   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("nearHundred count: \(nearHundred.count)")
        return filteredNearHundred.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointOfInterestCell", for: indexPath)

        
        let item = filteredNearHundred[indexPath.row]
        cell.textLabel?.text = item.name
        
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
            return poi.name.lowercased().contains(searchText.lowercased())
            })
        
            self.pointOfInterestTableView.reloadData()
        }
        
    }*/
    
    
    
}







