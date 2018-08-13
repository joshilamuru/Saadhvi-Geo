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
                //    syncPOItoServer(place: newPlace)
                    _ = navigationController?.popViewController(animated: true)
                }
            }catch{
                print("Error adding place to realm \(error)")
            }
            
        }
        
    }
    
    func syncPOItoServer(place: POI) {
        let urlstring = Constants.Domains.Stag + Constants.createPOI
        let url = URL(string: urlstring)
        let username = UserDefaults.standard.value(forKey: "username") as? String
        var keychainPassword = ""
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: username!,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            keychainPassword = try passwordItem.readPassword()
            
        } catch {
            fatalError("Error reading password from keychain - \(error)")
        }
        let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .short, timeStyle: .full)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let values = [
                        "accounts":[
                                    "accountIDFrmMobile": place.accountID,
                                    "accountID": "0",                                                                          
                                    "accountName": place.name,
                                    "taskDescription": place.name,
                                    "dueDate": "0",
                                    "dueTime": "0",
                                    "remindDate": "0",
                                    "remindTime": "0",
                                    "taskLat": 0,
                                    "taskLng": 0,
                                    "taskAddress": "",
                                    "sync": "Synched",
                                    "markedAsDone": 0,
                                    "createdDate": timestamp,
                                    "shortNotes": "",
                                    "snotesId": 0,
                                    "taskStatus": "",
                                    "TasktypeID": 295,
                                    "Others": "{}",
                                    "SpecialColumnValue": "",
                                    "IsFavourite": 0,
                                    "TaskDifferentiation": "M",
                                    "AutoGenFieldNo": "",
                                    "ReferenceNo": ""
                        ],
                        "eMail": username,
                        "password": keychainPassword,
                        "mobileIMEINumber": "911430509678238"
            ] as [String : Any]
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        
        Alamofire.request(request)
            .responseJSON { response in
                // do whatever you want here
                switch response.result {
                case .failure(let error):
                    print(error)
                    
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print(responseString)
                    }
                case .success(let responseObject):
                    print(responseObject)
                }
        }
    }
    func syncsPOItoServer(place: POI) {
        let url = Constants.Domains.Stag + Constants.createPOI
        let username = UserDefaults.standard.value(forKey: "username") as? String
        var keychainPassword = ""
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: username!,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            keychainPassword = try passwordItem.readPassword()
            
        } catch {
            fatalError("Error reading password from keychain - \(error)")
        }
        let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .short, timeStyle: .full)
//        var jsonArray: JSON = [
//            "accounts":[
//                        "taskIDFrmMobile": place.accountID,
//                        "accountID": "0",                                                                           //
//                        "accountName": place.name,
//                        "taskDescription": place.name,
//                        "dueDate": "0",
//                        "dueTime": "0",
//                        "remindDate": "0",
//                        "remindTime": "0",
//                        "taskLat": 0,
//                        "taskLng": 0,
//                        "taskAddress": "",
//                        "sync": "Synched",
//                        "markedAsDone": 0,
//                        "createdDate": timestamp,
//                        "shortNotes": "",
//                        "snotesId": 0,
//                        "taskStatus": "",
//                        "TasktypeID": 295,
//                        "Others": "{}",
//                        "SpecialColumnValue": "",
//                        "IsFavourite": 0,
//                        "TaskDifferentiation": "M",
//                        "AutoGenFieldNo": "",
//                        "ReferenceNo": ""
//            ],
//            "eMail": username,
//            "password": keychainPassword,
//            "mobileIMEINumber": "911430509678238"
//        ]
        let para:NSMutableDictionary = NSMutableDictionary()
        let acctArray:NSMutableArray = NSMutableArray()
        
        para.setValue(username, forKey: "eMail")
        para.setValue(keychainPassword, forKey: "password")
        para.setValue("911430509678238", forKey: "mobileIMEINumber")
        
      //  for product in products
      //  {
            let acct: NSMutableDictionary = NSMutableDictionary()
            acct.setValue(place.name, forKey: "name")
            acct.setValue(place.accountID, forKey: "taskIDFrmMobile")
            acct.setValue("0", forKey: "accountID")
            acct.setValue(place.name, forKey: "accountName")
            acct.setValue(place.name, forKey: "taskDescription")
            acct.setValue("0", forKey: "dueDate")
            acct.setValue("0", forKey: "dueTime")
            acct.setValue(place.latitude, forKey: "taskLat")
            acct.setValue(place.longitude, forKey: "taskLng")
            acct.setValue(place.address, forKey: "taskAddress")
            acct.setValue("sync", forKey: "Synched")
            acct.setValue(0, forKey: "markedAsDone")
            acct.setValue(timestamp, forKey: "createdDate")
            acct.setValue("", forKey: "shortNotes")
            acct.setValue(0, forKey: "snotesId")
            acct.setValue("", forKey: "taskStatus")
            acct.setValue(295, forKey: "TasktypeID")
            acct.setValue("{}", forKey: "Others")
            acct.setValue("", forKey: "SpecialColumnValue")
            acct.setValue(0, forKey: "IsFavourite")
            acct.setValue("M", forKey: "TaskDifferentiation")
            acct.setValue("", forKey: "AutoGenFieldNo")
            acct.setValue("", forKey: "ReferenceNo")
        acctArray.add(acct)
       // }
        
        para.setObject(acctArray, forKey: "accounts" as NSCopying)
        let input : [String: Any] = para as! [String : Any]
     

        Alamofire.request(url, method: HTTPMethod.post, parameters: input, encoding: JSONEncoding.default, headers: nil).responseJSON
            {
                (response) in
                
                print(response.request as Any)
                print(response.response as Any)
                print(response.result.value as Any)
                
                if response.result.isSuccess{
                   print("Success in sending poi to server")
                }
                else {
                    print("Error \(response.result.error)")
                    
                    
                }
        }
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
   
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        
       print("from didchangecamera position")
    }
    
    func locationData(location: CLLocation) {
        currentLocation = location
        print("success  \(currentLocation)")
    }
    //NOT WORKING >>>NEED TO FIND OUT
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addPlaceSegue") {
            let destinationVC = segue.destination as! MapViewController
          
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
        print("Place address: \(place.formattedAddress)")
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



