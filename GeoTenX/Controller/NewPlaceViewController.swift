//
//  NewPlaceViewController.swift
//  GeoTenX
//
//  Created by saadhvi on 9/6/18.
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

class NewPlaceViewController: FormViewController, GMSMapViewDelegate {
    
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
    var valArray: [String: Any?]!
    
    @IBOutlet weak var newPlaceMapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
         NotificationCenter.default.addObserver(self, selector: #selector(NewPlaceViewController.locationUpdateNotification(_:)), name: NSNotification.Name(rawValue: kLocationDidChangeNotification), object: nil)
        customFields = getCustomFieldsByAccountTypeID(ID: acctTypeID)
        if(!(customFields?.isEmpty)!){
            loadForm()
        }else{
            let str = NSLocalizedString("No custom fields available. Try again", comment: "No custom fields available. Try again")
            
            showAlertMessage(message: str)
            
        }
        setUpMap()
        newPlaceMapView.delegate = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

        @objc func locationUpdateNotification(_ notification: Notification){
            currentLocation = notification.userInfo?["value"] as! CLLocation
            print("Latitude from New Place VC: \(self.currentLocation.coordinate.latitude)")
            print("Longitude from New Place VC : \(self.currentLocation.coordinate.longitude)")
        }
        
    func locationDidUpdateToLocation(location: CLLocation) {
        currentLocation = location
        print(currentLocation)
       
    }
        
        func getCustomFieldsByAccountTypeID(ID: String) -> Results<AccountTypeCustomField>{
            
            let realm = try! Realm()
            let fields = realm.objects(AccountTypeCustomField.self).filter("AccountTypeID == %@", ID)
            // let fields = realm.objects(CustomField.self).filter("TaskTypeID == '59'")
            
            return fields
        }
        
        func loadForm() {
            
            let sectStr = NSLocalizedString("New Place Info", comment: "Account Info")
            form +++ Section(sectStr)
            
            // let section = form.sectionBy(tag: "Account Info")
            for field in customFields! {
                switch(field.EntryType) {
                case "Text":
                    
                    self.form.last! <<< TextRow(){ row in
                        
                        row.tag = field.DisplayName
                        row.title = field.DisplayName
                        row.placeholder = field.Desc
                        if(row.title == "Name" || row.title == "Name of Place" || row.title == "Address") {
                            row.add(rule: RuleRequired())
                            row.validationOptions = .validatesOnBlur
                        }
                        }.cellUpdate { cell, row in
                            if !row.isValid {
                                cell.titleLabel?.textColor = .red
                                var errors = ""
                                
                                for error in row.validationErrors {
                                    let errorString = error.msg + "\n"
                                    errors = errors + errorString
                                }
                                print(errors)
                               // self.showAlertMessage(message: "Field cannot be empty")
                            }
                            
                    }
                    
                case "Number":
                    self.form.last! <<< IntRow(){ row in
                        row.tag = field.FieldName
                        row.title = field.DisplayName
                        row.placeholder = field.Desc
                        
                    }
                case "Date","Time":
                    self.form.last! <<< DateTimeRow(){ row in
                        row.tag = field.FieldName
                        row.title = field.DisplayName
                        
                    }
                case "Image Upload", "Camera":
                    self.form.last! <<< ImageRow(){ row in
                        row.tag = field.FieldName
                        row.title = field.DisplayName
                        row.sourceTypes = .Camera
                        row.clearAction = .yes(style: .default)
                        
                        }
                    
                case "Option", "Auto Text":
                    self.form.last! <<< PushRow<String>(){
                        $0.tag = field.FieldName
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
                        $0.tag = field.FieldName
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
                        $0.tag = field.FieldName
                        $0.title = field.DisplayName
                        $0.presentationMode = .segueName(segueName: "DualCameraSegue", onDismiss: nil)
                    }
                    
                default:
                    print("no custom fields - \(field.EntryType)")
                    
                }
                
            }
            
            self.form.last! <<< ButtonRow() {
                
                $0.title = NSLocalizedString("Add New Place", comment: "Add New Place")
                }.cellUpdate { cell, row in
                    cell.textLabel?.textColor = UIColor.orange
                    cell.backgroundColor = UIColor.darkGray }.onCellSelection
                        { cell, row in
                            if (self.form.validate().count != 0){
                                print(self.form.validate())
                                self.showAlertMessage(message: "Field cannot be empty")
                            }else {
                            
                                let formValues = self.form.values()
                                
                                //perform segue and save user input
                               
                                self.saveFormValues(values: formValues)
                            }
                            
                        }
        }
   
    
    
    func saveFormValues(values: [String: Any?]){
        valArray = values
        for val in values {
            if(val.value is UIImage) {
                let image = val.value
                let data = UIImageJPEGRepresentation(image as! UIImage, 0.8)
                valArray[val.key] = data
            }
        }
        savePlace(values: valArray)
    }
    
    
    func savePlace(values: [String: Any?]){
        let newPlace = POI()
        
        if let name = values["Name"] as? String, !name.isEmpty,let place = values["Place"] as? String, !place.isEmpty,let address = values["Address"] as? String, !address.isEmpty{
            
                newPlace.name = (values["Name"] as? String)! + "-" + (values["Place"] as? String)! + "-" + (values["Address"] as? String)!
        }else  if let place = values["Place"] as? String, !place.isEmpty,let address = values["Address"] as? String, !address.isEmpty{
            newPlace.name = (values["Place"] as? String)! + "-" + (values["Address"] as? String)!
        }else {
            newPlace.name = (values["Name"] as? String)!
        }
            if let address = values["Address"] as? String, !address.isEmpty {
                newPlace.address = (values["Address"] as? String)!
        }
        newPlace.latitude = marker.position.latitude
        newPlace.longitude = marker.position.longitude
        newPlace.AccountTypeID = Int(acctTypeID)!
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
//                        if let composeViewController = self.navigationController?.viewControllers[2] {
//                            print(composeViewController)
//                            self.navigationController?.popToViewController(composeViewController, animated: true)
//                        }
                        
                    }else{
                       // let str = NSLocalizedString("Lost internet connection. Please connect to internet", comment: "Lost internet connection. Please connect to internet")
                        //showAlertMessage(message: str)
                        let formatAlert = NSLocalizedString("Alert", comment: "Alert")
                        let alert = UIAlertController(title: formatAlert, message: "Lost internet connection.Place saved locally. It will be synced once internet connection is available.", preferredStyle: UIAlertControllerStyle.alert)
                        let formatOK = NSLocalizedString("OK", comment: "OK")
                        alert.addAction(UIAlertAction(title: formatOK, style: .default, handler: {(_) in
                            
                         self.navigationController?.popViewController(animated: true)
                        }))
                         self.present(alert, animated: true, completion: nil)
                       
                    }
                   //   _ = navigationController?.popViewController(animated: true)
                }else{
                    showAlertMessage(message: "Place already exists")
                }
            }
        }catch{
            print("Error adding place to realm \(error)")
        }
        
    }
        func setUpMap(){
            
            camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude,longitude: currentLocation.coordinate.longitude, zoom: 20)
            newPlaceMapView.camera = camera
            newPlaceMapView.setMinZoom(15, maxZoom: 20)
            newPlaceMapView.isMyLocationEnabled = true
            newPlaceMapView.settings.myLocationButton = true
            print("current location in New Place vc: \(currentLocation)")
            //        let gmsCircle = GMSCircle(position: currentLocation.coordinate, radius: 100)
            //        let update = GMSCameraUpdate.fit(gmsCircle.bounds())
            //        newPlacMapView.animate(with: update)
            setMarkerAddress(pos: currentLocation.coordinate)
            marker.position = currentLocation.coordinate
            marker.isDraggable = true
            marker.map = self.newPlaceMapView
            
            
            
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
                newPlaceMapView.animate(to: camera)
                
            }
        }
        
        func setMarkerAddress(pos: CLLocationCoordinate2D) {
            let geocoder = GMSGeocoder()
            
            geocoder.reverseGeocodeCoordinate(pos) { response, error in
                guard let address = response?.firstResult(), let lines = address.lines else {
                    return
                }
            //    self.valArray["AccountAddress"] = lines.joined(separator: "\n")
               
               // let row = self.form.rowBy(tag: "Address") as! TextRow
                if let row = self.form.rowBy(tag: "Address") as? TextRow{
                    row.value = lines.joined(separator: "\n")
                    row.reload()
                }
            }
            
        }
        
        private func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
            
            print("from didchangecamera position")
        }
        
        func locationData(location: CLLocation) {
            currentLocation = location
            print("success  \(currentLocation)")
        }
       
        
      
     
        
        //MARK : Autocomplete search delegate methods
        
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = NSLocalizedString("Account Types", comment: "Types of Accounts")
    }
    override func viewWillDisappear(_ animated: Bool) {
        
       NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kLocationDidChangeNotification), object: nil)
    }
}
