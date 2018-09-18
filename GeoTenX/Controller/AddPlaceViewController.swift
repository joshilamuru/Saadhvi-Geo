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
import Eureka
import ImageRow

class AddPlaceViewController:
    FormViewController, GMSAutocompleteViewControllerDelegate, GMSMapViewDelegate
{
    
    @IBOutlet weak var PlaceFieldsView: UIView!
    @IBOutlet weak var newPlacMapView: GMSMapView!
    
    @IBOutlet weak var customerTextField: UITextField!
    
    @IBOutlet weak var placeTextField: UITextField!
  
    @IBOutlet weak var addressTextView: UITextView!
    var acctTypeID: String = ""
    var customFields: Results<AccountTypeCustomField>? = nil
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
        customFields = getCustomFieldsByAccountTypeID(ID: acctTypeID)
            if(!(customFields?.isEmpty)!){
                loadForm()
            }else{
                let str = NSLocalizedString("No custom fields available. Try again", comment: "No custom fields available. Try again")
                
                showAlertMessage(message: str)
            }
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
    
    func getCustomFieldsByAccountTypeID(ID: String) -> Results<AccountTypeCustomField>{
        
        let realm = try! Realm()
        let fields = realm.objects(AccountTypeCustomField.self).filter("AccountTypeID == %@", ID)
        // let fields = realm.objects(CustomField.self).filter("TaskTypeID == '59'")
        
        return fields
    }
    
    func loadForm() {
        
        let sectStr = NSLocalizedString("New Place Info", comment: "Account Info")
        form +++ Section()
        
        // let section = form.sectionBy(tag: "Account Info")
        for field in customFields! {
            switch(field.EntryType) {
            case "Text":
                
                self.form.last! <<< TextRow(){ row in
                    row.title = field.DisplayName
                    row.placeholder = field.Desc
                }
                
            case "Number":
                self.form.last! <<< IntRow(){ row in
                    row.title = field.DisplayName
                    row.placeholder = field.Desc
                    
                }
            case "Date","Time":
                self.form.last! <<< DateTimeRow(){ row in
                    row.title = field.DisplayName
                    
                }
            case "Image Upload":
                self.form.last! <<< ImageRow(){ row in
                    row.title = field.DisplayName
                    row.sourceTypes = .Camera
                    row.clearAction = .yes(style: .default)
                    
                }
                
            case "Option", "Auto Text":
                self.form.last! <<< PushRow<String>(){
                    $0.title = field.DisplayName
                    let values = (field.DefaultValues).components(separatedBy: ",")
                    print("Values are: \(values)")
                    $0.options = values
                    $0.value = ""
                    let strOption = NSLocalizedString("Choose an option", comment: "Choose an option")
                    $0.selectorTitle = strOption
                    }.onPresent{from, to in
                        to.dismissOnSelection = true
                        to.dismissOnChange = false
                }
            case "Choice":
                self.form.last! <<< MultipleSelectorRow<String> {
                    $0.title = field.DisplayName
                    let values = (field.DefaultValues).components(separatedBy: ",")
                    print("Values are: \(values)")
                    $0.options = values
                    $0.value = [""]
                    }.onPresent{from, to in
                        to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(DynamicFormViewController.multipleSelectorDone(_:)))
                        
                }
                
            case "Dual Camera":
                self.form.last! <<< PushRow<String>() {
                    $0.title = field.DisplayName
                    $0.presentationMode = .segueName(segueName: "DualCameraSegue", onDismiss: nil)
                }
               
            default:
                print("no custom fields - \(field.EntryType)")
                
            }
            
        }
    
        self.form.last! <<< ButtonRow("Add New Place") {
            
            $0.title = NSLocalizedString("Add New Place", comment: "Add New Place")
            }.cellUpdate { cell, row in
                cell.textLabel?.textColor = UIColor.orange
                cell.backgroundColor = UIColor.darkGray }
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
            
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let date = dateFormatterGet.string(from: Date())
            print("DATE FORMATTED: \(date)")
        newPlace.createdDate = date
           // newPlace.createdDate = timeNow()
         print("Formatted date from timeNow(): \(newPlace.createdDate)")
            newPlace.fromServer = false
            newPlace.synced = false
      
        
            do{
                try realm.write{
                    //check for duplicate before adding to realm
                    if(chkUnique(place: newPlace)){
                        realm.add(newPlace)
                        
                        if (NetworkManager.sharedInstance.reachability).connection != .none {
                            
                        SyncAcctToServer.SharedSyncInstance.syncData()
                        
                        _ = navigationController?.popViewController(animated: true)
                        }else{
                            let str = NSLocalizedString("Lost internet connection. Please connect to internet", comment: "Lost internet connection. Please connect to internet")
                            showAlertMessage(message: str)
                        }
                    }else{
                        showAlertMessage(message: "Place already exists")
                    }
                }
            }catch{
                print("Error adding place to realm \(error)")
            }
            
     //   }
        
    }
    
    func chkUnique(place: POI) -> Bool{
        
        let POIs = realm.objects(POI.self)
        for poi in POIs {
            if(place.name == poi.name){
                
                return false
            }
            
        }
       return true
        
    }
    func timeNow()->String{
        df.setLocalizedDateFormatFromTemplate("dd-MM-yyyy HH:mm:ss")
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



