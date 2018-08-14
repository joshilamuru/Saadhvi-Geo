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

class AcctDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var DetailsTableView: UITableView!
    var poi : PointOfInterest!
    @IBOutlet weak var mapView: GMSMapView!
    var acctLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMap()
        DetailsTableView.delegate = self
        DetailsTableView.dataSource = self
        
        //register for xib file
        DetailsTableView.register(UINib(nibName: "DetailsCell", bundle: nil), forCellReuseIdentifier: "customDetailCell")
        configureTableView()
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
    
    @IBAction func ChkInPressed(_ sender: Any) {
        performSegue(withIdentifier: "formSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "formSegue") {
            let destinationVC = segue.destination as! DynamicFormViewController
            destinationVC.acct = poi.address
            destinationVC.taskTypeID = poi.taskTypeID
            
            navigationItem.title = " "
            destinationVC.navigationItem.title = "Form Details"
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
            cell.ItemName.text = "Notes"
            cell.ItemDescription.text = poi.shortNotes
        }else if(indexPath.row  == 4 ){
            cell.ItemName.text = "Task Status"
            cell.ItemDescription.text = poi.taskStatus
        }
        return cell
    }
    
  //configure tableview
    func configureTableView() {
        DetailsTableView.rowHeight = UITableViewAutomaticDimension
        DetailsTableView.estimatedRowHeight = 120.0
    }
   
}

