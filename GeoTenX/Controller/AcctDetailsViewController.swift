//
//  AcctDetailsViewController.swift
//  sampleForGeo
//
//  Created by saadhvi on 8/9/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

class AcctDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LocationUpdateProtocol {

    @IBOutlet weak var DetailsTableView: UITableView!
   // var poi : PointOfInterest!
    var poi: POI!
    @IBOutlet weak var mapView: GMSMapView!
    var acctLocation = CLLocation()
    var currentLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(AcctDetailsViewController.locationUpdateNotification(_:)), name: NSNotification.Name(rawValue: kLocationDidChangeNotification), object: nil)
        initMap()
        DetailsTableView.delegate = self
        DetailsTableView.dataSource = self
        
        //register for xib file
        DetailsTableView.register(UINib(nibName: "DetailsCell", bundle: nil), forCellReuseIdentifier: "customDetailCell")
        //configureTableView()
    }
    @objc func locationUpdateNotification(_ notification: Notification) {
        let userinfo = notification.userInfo
        self.currentLocation = userinfo!["location"] as! CLLocation
        print("Latitude from AcctDetails: \(self.currentLocation.coordinate.latitude)")
        print("Longitude from AcctDetails : \(self.currentLocation.coordinate.longitude)")
        
    }
    
    func locationDidUpdateToLocation(location: CLLocation) {
        currentLocation = location
        print("location from notification in acctDetails : \(currentLocation)")
        
    }
    func initMap() {
        let camera = GMSCameraPosition.camera(withLatitude: (acctLocation.coordinate.latitude),longitude: (acctLocation.coordinate.longitude), zoom: 25)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: (acctLocation.coordinate.latitude) , longitude: (acctLocation.coordinate.longitude))
        marker.map = mapView
        self.mapView.animate(toLocation: marker.position)
        
        
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "tasksSegue") {
            let destinationVC = segue.destination as! TaskTypesViewController
            destinationVC.currentLocation = currentLocation
            navigationItem.title = " "
            destinationVC.navigationItem.title = "Task Types"
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customDetailCell", for: indexPath) as! CustomDetailsViewCell
        
        if(indexPath.row == 0){
            cell.ItemName.text = "Account Name"
            cell.ItemDescription.text = poi.name
        }else if(indexPath.row == 1){
            cell.ItemName.text = "Account Address"
            cell.ItemDescription.text = poi.address
        }else if(indexPath.row  == 2){
            cell.ItemName.text = "Created Date"
            cell.ItemDescription.text = poi.createdDate
        }else if(indexPath.row  == 3 ){
            cell.ItemName.text = "Account Description"
            cell.ItemDescription.text = poi.AccountDescription
        }else if(indexPath.row  == 4 ){
            cell.ItemName.text = "Status"
            cell.ItemDescription.text = poi.status
        }
        return cell
    }
   
    override func viewWillAppear(_ animated: Bool) {
        DetailsTableView.rowHeight = UITableViewAutomaticDimension
        DetailsTableView.estimatedRowHeight = 120.0
        navigationItem.title = NSLocalizedString("Account Details", comment: "Account Details")
    }
 
   
}

