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
import Alamofire
import SwiftyJSON
class DynamicFormViewController: FormViewController, LocationUpdateProtocol, MergedImagesProtocol {
   private let preview = PreviewViewController()
    
    var currentLocation = CLLocation()
    var taskTypeName : String = ""
    var taskTypeID : Int!
    // var acctTypeID: Int!
    var valArray: [String: Any?]!
    var poi: POI!
    var customFields: Results<CustomField>? = nil
    let realm = try! Realm()
    var mergedImg: UIImage?
    var rowTag: String?
    var name: String = ""
    var formValues: [String: Any?]!
    var images = [String: UIImage]()
    var task: Task!
   // var preview: PreviewViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(task)
        preview.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(DynamicFormViewController.locationUpdateNotification(_:)), name: NSNotification.Name(rawValue: kLocationDidChangeNotification), object: nil)
        let LocationMgr = LocationService.SharedManager
        LocationMgr.delegate = self
        let str = NSLocalizedString("Check-In", comment: "Check-In")
        self.navigationItem.title = str
      
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
    
    func mergeImages(img: [String : UIImage]) {
        for item in img {
            images[item.key] = item.value
        }
        for image in images{
            print("rowtag from mergeImages: \(image.key)")
            let row = form.rowBy(tag: image.key)
            row?.baseCell.textLabel?.text = "Image saved"
            row?.updateCell()
        }
    }
    func loadForm() {
    
        let sectStr = NSLocalizedString("\(taskTypeName)", comment: "Task type name")
        
        form +++ Section(sectStr)
        // let section = form.sectionBy(tag: "Account Info")
        for field in customFields! {
            switch(field.EntryType) {
            case "Text":
                
                self.form.last! <<< TextRow(){ row in
                    row.tag = field.FieldName
                    row.title = field.DisplayName
                    row.placeholder = field.Desc
                }
                
            case "Number":
                self.form.last! <<< IntRow(){ row in
                    row.tag = field.FieldName
                    row.title = field.DisplayName
                    row.placeholder = field.Desc
                    
                }
            case "Date":
                self.form.last! <<< DateTimeRow(){ row in
                    row.tag = field.FieldName
                    row.title = field.DisplayName
                    
                }
            case "Time":
                self.form.last! <<< DateTimeRow(){ row in
                    row.dateFormatter?.dateFormat = "HH:mm:ss"
                    row.tag = field.FieldName
                    row.title = field.DisplayName
                    
                }
//            case "Image Upload":
//                self.form.last! <<< ImageRow(){ row in
//                    row.tag = field.FieldName
//                    row.title = field.DisplayName
//                    row.sourceTypes = .Camera
//                    row.clearAction = .yes(style: .default)
//
//                }
//
            case "Option", "Auto Text":
                self.form.last! <<< PushRow<String>(){
                    $0.tag = field.FieldName
                    $0.title = field.DisplayName
                    let values = (field.DefaultValues).components(separatedBy: ",")
                  //  print("Values are: \(values)")
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
                    //print("Values are: \(values)")
                    $0.options = values
                    $0.value = [""]
                    }.onPresent{from, to in
                        to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(DynamicFormViewController.multipleSelectorDone(_:)))
                        
                }
      
            case "Dual Camera", "Image Upload":
                self.form.last! <<< ButtonRow() {
                    $0.tag = field.FieldName
                    $0.title = field.DisplayName
                    name = $0.tag! + "-" + "copy.png"
                    $0.presentationMode = .segueName(segueName: "DualCameraSegue", onDismiss: nil)
                    $0.cell.imageView?.image = self.images[$0.tag!]
                    }
                   .cellUpdate { cell, row in
                  //  print(self.images.count)
                    cell.imageView?.image = self.images[row.tag!]
//                    let endIndex = self.name.range(of: "-")!.lowerBound
//                    let str = self.name.substring(to: endIndex).trimmingCharacters(in: .whitespacesAndNewlines)
//                    print("str:\(str)")
//                    print("rowTag: \(self.rowTag)")
//
//                    if str == self.rowTag{
//
//                                    cell.imageView?.image = self.mergedImg
//                       
//                    }

                    
                    }
                
                
            default:
                print("no custom fields - \(field.EntryType)")
                
            }
            
        }
       
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        if segue.identifier == "DualCameraSegue" {
            let destinationVC = segue.destination as! DualCameraViewController
             rowTag = (sender as! ButtonRow).tag!
            destinationVC.rowTag = rowTag!
            destinationVC.dynamicVC = self
        }
    }
    @IBAction func saveBtnPressed(_ sender: Any) {
        formValues = self.form.values()
     //   print(formValues)
        //add images obtained via preview vc
        for item in images{
            
            print(item.key)
            formValues[item.key] = item.value
            
        }
        self.saveFormValues(values: formValues)
      //  name = ""
    }
    
    func saveFormValues(values: [String: Any?]){
        var valWithoutNil: [String: Any] = [:]
        for item in values{
            if let someVal = item.value {
            
               valWithoutNil[item.key] = someVal
            }
         
        }
        //remove null values
        
        valArray = valWithoutNil
      
        for val in values {
            if(val.value is UIImage) {
//                //let imageData = UIImagePNGRepresentation(val.value as! UIImage)
//                let imageResized = (val.value as! UIImage).resized(withPercentage: 0.1)
//                let imageData = UIImageJPEGRepresentation(imageResized!, 0.0)
//                print("SIZE OF IMAGE:\(imageData?.count)")
//                let imageStr = imageData?.base64EncodedString(options:.lineLength64Characters)
//                print("SIZE OF IMAGE STR: \(imageStr?.lengthOfBytes(using: .utf8))")
//                valArray[val.key] = imageStr
//
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
               
                let timestamp = dateFormatter.string(from: Date())
                let imageData = UIImageJPEGRepresentation(val.value as! UIImage, 1.0)
                //send imageData to server via WSUploadSignature.do
                
                uploadImage(parameters: ["fileID": UUID().uuidString,"fileName": val.key + timestamp + ".jpg"], imageData: imageData!)
                valArray[val.key] = ""
                
            }else if(val.value is NSSet){
        
                let strArr: NSArray = (val.value as! NSSet).allObjects as NSArray
            
                let strVal = strArr.componentsJoined(by: ",")
                valArray.updateValue(strVal, forKey: val.key)
                
            }else if(val.value is NSDate){
                 let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let dateStr = dateFormatter.string(from: (val.value as! Date))
                valArray.updateValue(dateStr, forKey: val.key)
            }else if(val.value is NSNull){
                valArray.updateValue(nil, forKey: val.key)
            }
        }
        saveTaskDetails(values: valArray)
    }
    
    
    
        func uploadImage(parameters: [String : String], imageData: Data?, onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
            
            let url = Constants.Domains.Stag + Constants.uploadImage
            
            let headers: HTTPHeaders = [
                /* "Authorization": "your_access_token",  in case you need authorization header */
                "Content-type": "multipart/form-data"
            ]
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                for (key, value) in parameters {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
                
                if let data = imageData{
                   multipartFormData.append(data, withName: "image", fileName: "image.png", mimeType: "image/png")
                 
                  
                }
                
            }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
                switch result{
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        print("Succesfully uploaded")
                        if let err = response.error{
                            onError?(err)
                            return
                        }
                        onCompletion?(nil)
                    }
                case .failure(let error):
                    print("Error in upload: \(error.localizedDescription)")
                    onError?(error)
                }
            }
        }

    
    func saveTaskDetails(values: [String: Any?]) {

        
                    let task = Task()
                    task.taskLat = self.currentLocation.coordinate.latitude
                    task.taskLng = self.currentLocation.coordinate.longitude
                    task.TasktypeID = taskTypeID
                    task.accountID = "\(poi.accountID)"
                    let dateFormatterGet = DateFormatter()
                    dateFormatterGet.dateFormat = "dd-MM-yyyy HH:mm:ss"
                    let date = dateFormatterGet.string(from: Date())
                    print("DATE FORMATTED: \(date)")
                    task.createdDate = date
                   // task.taskAddress = currentLocation.coordinate
                    task.synced = false
        
        
        
                    task.Others = updateLocDetailsInOthers(data: values)
                 //   print("from saveTaskDetails- Others:\(task.Others)")
        
        
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
    
    func getImageFromDir(name: String)-> UIImage{
        let fileManager = FileManager.default
    
        let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(name)
    
        if fileManager.fileExists(atPath: imagePAth){
            
            mergedImg = UIImage(contentsOfFile: imagePAth)
            
            }else{
            
            print("No Image")
            
      }
        return mergedImg!
    }
        func getDirectoryPath() -> String {
            
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            
            let documentsDirectory = paths[0]
            return documentsDirectory
            
        }
    
 
    func updateLocDetailsInOthers(data: [String: Any?]) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyyMMdd HHmmss"
        let date = dateFormatterGet.string(from: Date())
        let latStr: String = String(format:"%.14f", currentLocation.coordinate.latitude)
        let lngStr: String = String(format:"%.14f", currentLocation.coordinate.longitude)
        let others: NSMutableDictionary = NSMutableDictionary()
      //  let towerDetails:NSMutableDictionary = NSMutableDictionary()
        let tslDetails: NSMutableDictionary = NSMutableDictionary()
       
        tslDetails.setValue(date, forKey: "ST")
        tslDetails.setValue(latStr, forKey: "Lat")
        tslDetails.setValue(lngStr, forKey: "Lng")
        tslDetails.setValue("0", forKey: "AL")
        tslDetails.setValue("0", forKey: "LP")
        tslDetails.setValue(0, forKey: "cellId")
        tslDetails.setValue(0, forKey: "lacId")
        
        others.setObject(tslDetails, forKey: "TSL" as NSCopying)
        others.addEntries(from: data)
      //  others.setObject(towerDetails, forKey: "Others" as NSCopying)
        
      //  print(others)
        return json(obj: others)!
    }
    func json(obj:Any) -> String? {
    
        guard let data = try? JSONSerialization.data(withJSONObject: obj, options: []) else {
            return nil
        }
     //   print(data)
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
    override func viewDidAppear(_ animated: Bool) {
       
//        if let Tag = rowTag{
//            if let row = self.form.rowBy(tag: Tag){
//                let fileManager = FileManager.default
//
//                let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(self.name)
//
//                if fileManager.fileExists(atPath: imagePAth){
//
//                        self.mergedImg = UIImage(contentsOfFile: imagePAth)
//                        //self.form.rowBy(tag: "rowTag")?.updateCell()
//
//
//                    row.baseCell.imageView?.image = mergedImg
//                        row.updateCell()
//                  //  row.reload()
//                  //  self.tableView?.reloadData()
//                }
//        }
//    }
}
}
