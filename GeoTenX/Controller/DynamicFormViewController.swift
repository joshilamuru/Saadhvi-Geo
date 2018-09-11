//
//  DynamicFormViewController.swift
//  sampleForGeo
//
//  Created by saadhvi on 8/6/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift
import ImageRow
import CoreLocation
import GoogleMaps
import GooglePlaces

class DynamicFormViewController: FormViewController, LocationUpdateProtocol {
    var currentLocation = CLLocation()
    var taskTypeName : String = ""
    var taskTypeID : Int!
    // var acctTypeID: Int!
    var valArray: [String: Any]!
    @IBOutlet weak var acctLabel: UILabel!
    var customFields: Results<CustomField>? = nil
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(DynamicFormViewController.locationUpdateNotification(_:)), name: NSNotification.Name(rawValue: kLocationDidChangeNotification), object: nil)
        let LocationMgr = LocationService.SharedManager
        LocationMgr.delegate = self
        let str = NSLocalizedString("Check-In", comment: "Check-In")
        self.navigationItem.title = str
        acctLabel.text = taskTypeName
        customFields = getCustomFieldsByTaskID(ID: String(taskTypeID))
        if(!(customFields?.isEmpty)!){
            loadForm()
        }else{
            let str = NSLocalizedString("No custom fields available. Try again", comment: "No custom fields available. Try again")
            
            showAlertMessage(message: str)
        }
        }
    
    @objc func locationUpdateNotification(_ notification: Notification) {
        let userinfo = notification.userInfo
        self.currentLocation = userinfo!["location"] as! CLLocation
        print("Latitude from dynamicform: \(self.currentLocation.coordinate.latitude)")
        print("Longitude from dynamicform : \(self.currentLocation.coordinate.longitude)")
       
    }
    
    func locationDidUpdateToLocation(location: CLLocation) {
        currentLocation = location
        print("location from notification in dynamic form: \(currentLocation)")
        
    }

    func loadForm() {
    
        let sectStr = NSLocalizedString("Account Info", comment: "Account Info")
        form +++ Section(sectStr)
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
//                    .onPresent { from, to in
//                        to.selectableRowCellUpdate = { cell, row in
//                            print("here")
//                                cell.
//                                cell.textLabel!.textColor = UIColor.green
//                        }
           //             }
                
                
                
                
                
                
            default:
                print("no custom fields - \(field.EntryType)")
                
            }
            
        }
        //        for section in form.allSections {
        //            print("Section tags - \(section.tag)")
        //        }
        self.form.last! <<< ButtonRow("Save") {
            
            $0.title = NSLocalizedString("Save", comment: "Save")
            }.cellUpdate { cell, row in
                cell.textLabel?.textColor = UIColor.orange
                cell.backgroundColor = UIColor.darkGray }.onCellSelection
                    { cell, row in
                    
                    let formValues = self.form.values()
                    
                    self.saveFormValues(values: formValues)
                    }
                    
        
    }
    func saveFormValues(values: [String: Any]){
        valArray = values
        for val in values {
            if(val.value is UIImage) {
                let image = val.value
                let data = UIImageJPEGRepresentation(image as! UIImage, 0.8)
                valArray[val.key] = data
            }
        }
        saveTaskDetails(values: valArray)
    }
    
    
    
    func saveTaskDetails(values: [String: Any]) {


        let task = Task()
        
        GMSGeocoder().reverseGeocodeCoordinate(currentLocation.coordinate) { response, error in
            if let location = response?.firstResult() {
                
                let lines = location.lines! as [String]
                task.taskAddress = lines.joined(separator: "\n")
            }
        }

        task.taskLat = self.currentLocation.coordinate.latitude
        task.taskLng = self.currentLocation.coordinate.longitude

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let date = dateFormatterGet.string(from: Date())
        print("DATE FORMATTED: \(date)")
        task.createdDate = date
        task.synced = false
        
     
        
        task.Others = updateLocDetailsInOthers(data: values)
        
        do{
            try realm.write{
               
                
                    realm.add(task)
                    
                    if (NetworkManager.sharedInstance.reachability).connection != .none {
                        
                        SyncDataToServer.SharedSyncInstance.syncData()
                        
                        _ = navigationController?.popViewController(animated: true)
                        //                        if let composeViewController = self.navigationController?.viewControllers[2] {
                        //                            print(composeViewController)
                        //                            self.navigationController?.popToViewController(composeViewController, animated: true)
                        //                        }
                        
                    }else{
                        
                        let formatAlert = NSLocalizedString("Alert", comment: "Alert")
                        let alert = UIAlertController(title: formatAlert, message: "Lost internet connection.Place saved locally. It will be synced once internet connection is available.", preferredStyle: UIAlertControllerStyle.alert)
                        let formatOK = NSLocalizedString("OK", comment: "OK")
                        alert.addAction(UIAlertAction(title: formatOK, style: .default, handler: {(_) in
                            
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    //   _ = navigationController?.popViewController(animated: true)
                
            }
        }catch{
            print("Error adding data \(error)")
        }
        
        }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func multipleSelectorDone(_ item: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func updateLocDetailsInOthers(data: [String: Any]) -> String {
        
        let others: NSMutableDictionary = NSMutableDictionary()
        
        let tslDetails: NSMutableDictionary = NSMutableDictionary()
       let tulDetails: NSMutableDictionary = NSMutableDictionary()
        tslDetails.setValue("", forKey: "ST")
        tslDetails.setValue("", forKey: "Lat")
        tslDetails.setValue("", forKey: "Lng")
        tslDetails.setValue("", forKey: "AL")
        tslDetails.setValue("", forKey: "LP")
        tslDetails.setValue("", forKey: "cellId")
        tslDetails.setValue("", forKey: "lacId")
        
        
        tulDetails.setValue("", forKey: "UT")
        tulDetails.setValue("", forKey: "Lat")
        tulDetails.setValue("", forKey: "Lng")
        tulDetails.setValue("", forKey: "AL")
        tulDetails.setValue("", forKey: "LP")
        tulDetails.setValue("", forKey: "cellId")
        tulDetails.setValue("", forKey: "lacId")
        others.setObject(tulDetails, forKey: "TSL" as NSCopying)
         others.setObject(tulDetails, forKey: "TUL" as NSCopying)
        others.addEntries(from: data)
        return json(obj: others)!
    }
    func json(obj:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: obj, options: []) else {
            return nil
        }
        print(data)
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    func getCustomFieldsByTaskID(ID: String) -> Results<CustomField>{
        
        let realm = try! Realm()
        let fields = realm.objects(CustomField.self).filter("TaskTypeID == %@", ID)
    
        return fields
    }
 
    func showAlertMessage(message: String){
        let formatAlert = NSLocalizedString("Alert", comment: "Alert")
        let alert = UIAlertController(title: formatAlert, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let formatOK = NSLocalizedString("OK", comment: "OK")
        alert.addAction(UIAlertAction(title: formatOK, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kLocationDidChangeNotification), object: nil)
    }
   
}

