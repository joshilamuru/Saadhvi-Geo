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
    
    @IBOutlet weak var customerTextField: UITextField!
    
    @IBOutlet weak var placeTextField: UITextField!
  
    @IBOutlet weak var addressTextView: UITextView!
    var currentLocation = CLLocation()
    var marker = GMSMarker()
    let realm = try! Realm()
    var bounds = GMSCoordinateBounds()
    var visibleRegion = GMSVisibleRegion()
    var camera = GMSCameraPosition()
    let df = DateFormatter()
    let address: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        placeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
        print("Latitude from addplace: \(self.currentLocation.coordinate.latitude)")
        print("Longitude from addplace : \(self.currentLocation.coordinate.longitude)")
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        //errorPlaceLabel.isHidden = true
    }
    func setUpMap(){
        
        camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude,longitude: currentLocation.coordinate.longitude, zoom: 20)
        newPlacMapView.camera = camera
        newPlacMapView.setMinZoom(15, maxZoom: 20)
        newPlacMapView.isMyLocationEnabled = true
        newPlacMapView.settings.myLocationButton = true
        print("current location in appPlacevc: \(currentLocation)")
//        let gmsCircle = GMSCircle(position: currentLocation.coordinate, radius: 100)
//        let update = GMSCameraUpdate.fit(gmsCircle.bounds())
//        newPlacMapView.animate(with: update)
        setMarkerAddress(pos: currentLocation.coordinate)
        marker.position = currentLocation.coordinate
        marker.isDraggable = true
        marker.map = self.newPlacMapView
       
        
        
    }
    
    
    @IBAction func addPlacePressed(_ sender: Any) {
//        guard let text = placeTextField.text, !text.isEmpty else{
//            errorPlaceLabel.isHidden = false
//            return
//
//        }
        
        guard let text = placeTextField.text, !text.isEmpty else{
            let messStr = NSLocalizedString("Place name cannot be empty", comment: "Name of place cannot be empty")
            showAlertMessage(message: messStr)
            placeTextField.becomeFirstResponder()
            return
        }
        guard let _ = addressTextView.text, !text.isEmpty else{
            let messStr = NSLocalizedString("Address cannot be empty. Enter address", comment: "Address cannot be empty. Enter address")
            showAlertMessage(message: messStr)
            addressTextView.becomeFirstResponder()
            return
        }
        //else {
            
            let newPlace = POI()
            if let text = customerTextField.text, !text.isEmpty{
            newPlace.name = customerTextField.text!+"-" + placeTextField.text!+"-"+addressTextView.text!
            }
            else {
                newPlace.name = placeTextField.text!+"-"+addressTextView.text!
            }
            newPlace.address = addressTextView.text!
            newPlace.latitude = marker.position.latitude
            newPlace.longitude = marker.position.longitude
            
           
            let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .full, timeStyle: .full)
           newPlace.createdDate = timestamp
            //newPlace.createdDate = timeNow()
            newPlace.fromServer = false
            newPlace.synced = false
        
            do{
                try realm.write{
                    realm.add(newPlace)
                    if (NetworkManager.sharedInstance.reachability).connection != .none {
                        
                    SyncAcctToServer.SharedSyncInstance.syncData()
                    
                    _ = navigationController?.popViewController(animated: true)
                    }else{
                        let str = NSLocalizedString("Lost internet connection. Please connect to internet", comment: "Lost internet connection. Please connect to internet")
                        showAlertMessage(message: str)
                    }
                }
            }catch{
                print("Error adding place to realm \(error)")
            }
            
     //   }
        
    }
    
   
    func timeNow()->String{
        df.setLocalizedDateFormatFromTemplate("dd-mm-yyyy HH:MM:SS")
        return df.string(from: Date())
    }
    
    func showAlertMessage(message: String){
        let formatAlert = NSLocalizedString("Alert", comment: "Alert")
        let alert = UIAlertController(title: formatAlert, message: message, preferredStyle: UIAlertControllerStyle.alert)
         let formatOK = NSLocalizedString("OK", comment: "OK")
        alert.addAction(UIAlertAction(title: formatOK, style: .default, handler: nil))
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
            let formatMessage = NSLocalizedString("Please select a place within 100 mts of your current location", comment: "Please select a place within 100 mts of your current location")
            showAlertMessage(message: formatMessage)
           
       
            
        }
        else{
            marker.position = coordinate
            setMarkerAddress(pos: coordinate)
            
            camera = GMSCameraPosition.camera(withLatitude: newLat,longitude: newLong, zoom: 20)
            newPlacMapView.animate(to: camera)
            
        }
    }
   
    func setMarkerAddress(pos: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(pos) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            self.addressTextView.text = lines.joined(separator: "\n")
           
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



