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

class AcctDetailsViewController: UIViewController  {

    var poi : PointOfInterest!
    @IBOutlet weak var mapView: GMSMapView!
    var acctLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMap()
        
        // Do any additional setup after loading the view.
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
    

  
   
}

//extension AcctDetailsViewController: UITableViewDelegate, UITableViewDataSource{
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//    }
//    
//    
//}
