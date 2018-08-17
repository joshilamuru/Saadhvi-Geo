//
//  AddPlaceViewController.swift
//  sampleForGeo
//
//  Created by saadhvi on 6/21/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import RealmSwift
import SwiftyJSON
import Alamofire

class AddPlaceViewController:
    UIViewController, GMSAutocompleteViewControllerDelegate, GMSMapViewDelegate
{
    
    @IBOutlet weak var newPlacMapView: GMSMapView!
    
    @IBOutlet weak var errorPlaceLabel: UILabel!
    @IBOutlet weak var placeTextField: UITextField!
  
    var currentLocation = CLLocation()
    var marker = GMSMarker()
    let realm = try! Realm()
    var bounds = GMSCoordinateBounds()
    var visibleRegion = GMSVisibleRegion()
    var camera = GMSCameraPosition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(AddPlaceViewController.updateCurrentLocation), name: NSNotification.Name(rawValue: "currentLoc"), object: nil)
        
        /* let imageMarker = UIImageView(frame: CGRect(x: self.view.frame.width/2-25, y: self.view.frame.height/2-25, width: 50, height: 50))
         let myImage: UIImage = UIImage(named: "Icon-Small-50x50")!
         imageMarker.image = myImage
         */
        
        setUpMap()
        // self.view.addSubview(imageMarker)
        // self.view.bringSubview(toFront: imageMarker)
        newPlacMapView.delegate = self
    }
    
    @objc func updateCurrentLocation(notification: Notification){
        currentLocation = notification.userInfo?["value"] as! CLLocation
    }
    func setUpMap(){
        camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude,longitude: currentLocation.coordinate.longitude, zoom: 20)
        newPlacMapView.camera = camera
        newPlacMapView.setMinZoom(15, maxZoom: 20)
        //newPlacMapView.isMyLocationEnabled = true
        // newPlacMapView.settings.myLocationButton = true
        print("current location in appPlacevc: \(currentLocation)")
//        let gmsCircle = GMSCircle(position: currentLocation.coordinate, radius: 100)
//        let update = GMSCameraUpdate.fit(gmsCircle.bounds())
//        newPlacMapView.animate(with: update)
        
        marker.position = currentLocation.coordinate
        marker.isDraggable = true
        marker.map = self.newPlacMapView
       
        
        
    }
    
    
    @IBAction func addPlacePressed(_ sender: Any) {
        if(placeTextField.text?.count == 0){
            errorPlaceLabel.isHidden = false
        }
        else {
            
            let newPlace = POI()
            newPlace.name = placeTextField.text!
            newPlace.address = placeTextField.text!
            newPlace.latitude = marker.position.latitude
            newPlace.longitude = marker.position.longitude
            newPlace.synced = false
            do{
                try realm.write{
                    realm.add(newPlace)
                    if (NetworkManager.sharedInstance.reachability).connection != .none {
                        
                    SyncAcctToServer.SharedSyncInstance.syncData()
                    
                    _ = navigationController?.popViewController(animated: true)
                    }else{
                        showAlertMessage(message: "Lost internet connection. Please connect to internet")
                    }
                }
            }catch{
                print("Error adding place to realm \(error)")
            }
            
        }
        
    }
    
  
    func showAlertMessage(message: String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        marker.icon = GMSMarker.markerImage(with: .red)
        
    }
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        marker.icon = GMSMarker.markerImage(with: .green)
        let markerLocation = CLLocation(latitude: marker.position.latitude, longitude:marker.position.longitude)
        print(markerLocation)
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.title = "Location"
        marker.snippet = "Latitude: \(marker.position.latitude),Longitude: \(marker.position.longitude) "
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        let newLat = coordinate.latitude
        let newLong = coordinate.longitude
        let loc = CLLocation(latitude: newLat, longitude: newLong)
        if (currentLocation.distance(from: loc) > 100){
            let alert = UIAlertController(title: "Alert", message: "Please select a place within 100 mts of your current location", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        //    setUpMap()
            
        }
        else{
            marker.position = coordinate
           
            camera = GMSCameraPosition.camera(withLatitude: newLat,longitude: newLong, zoom: 20)
            newPlacMapView.animate(to: camera)
        }
    }
   
   
    private func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        
       print("from didchangecamera position")
    }
    
    func locationData(location: CLLocation) {
        currentLocation = location
        print("success  \(currentLocation)")
    }
    //NOT WORKING >>>NEED TO FIND OUT
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addPlaceSegue") {
          //  let destinationVC = segue.destination as! MapViewController
          
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchPlace(_ sender: Any) {
        let placePickerController = GMSAutocompleteViewController()
        placePickerController.delegate = self
        present(placePickerController, animated: true, completion: nil)
        
    }
    
    //MARK : Autocomplete search delegate methods
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress!)")
        dismiss(animated: true, completion: nil)
        newPlacMapView.clear()
        
        marker.position = place.coordinate
        marker.map = newPlacMapView
        self.newPlacMapView.animate(toLocation: place.coordinate)
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("error:", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}



