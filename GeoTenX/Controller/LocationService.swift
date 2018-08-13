//
//  LocationService.swift
//  sampleForGeo
//
//  Created by saadhvi on 7/4/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import Foundation
import CoreLocation
//Singleton locationservice

protocol LocationUpdateProtocol {
    func locationDidUpdateToLocation(location : CLLocation)
}
// Notification on update of location. UserInfo contains CLLocation for key "location"
let kLocationDidChangeNotification = "LocationDidChangeNotification"

class LocationService : NSObject, CLLocationManagerDelegate {
    static let SharedManager = LocationService()
    private var locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var delegate : LocationUpdateProtocol!
   
    override init() {
        super.init()
        initLocationManager()
        
    }
    
    func initLocationManager() {
        //Setup location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        //locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userInfo : NSDictionary
        
        currentLocation = locations[locations.count-1] //getting the last updated location which is most accurate
            
        if currentLocation.horizontalAccuracy > 0 {
                self.locationManager.stopUpdatingLocation()
                userInfo = ["location" : currentLocation]
            DispatchQueue.main.async() { () -> Void in
                self.delegate.locationDidUpdateToLocation(location: self.currentLocation)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLocationDidChangeNotification), object: self, userInfo: userInfo as? [AnyHashable : Any])
               
            }
            print("longitude = \(currentLocation.coordinate.longitude), latitude = \(currentLocation.coordinate.latitude)")
        }
    }
        
        //didFailWithError method
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print(error)
            
        }
    
    
        
    
}

