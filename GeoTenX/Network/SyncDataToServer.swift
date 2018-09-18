
//  Created by saadhvi on 8/10/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift
import Reachability
import CoreLocation

class SyncDataToServer : NSObject {
    static let SharedSyncInstance = SyncDataToServer()
    let realm = try! Realm()
    
    //declare this inside of viewWillAppear
    override init() {
        super.init()
        
    }
    
    func syncData(){
        
        
        let urlstring = Constants.Domains.Stag + Constants.createTask
        let url = URL(string: urlstring)
        let username = UserDefaults.standard.value(forKey: "username") as? String
        var keychainPassword = ""
        if let user = username{
            do {
                let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                        account: user,
                                                        accessGroup: KeychainConfiguration.accessGroup)
                keychainPassword = try passwordItem.readPassword()
                
            } catch {
                fatalError("Error reading password from keychain - \(error)")
            }
         //   let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .short, timeStyle: .full)
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //get accounts that are not synced from realm
        
            let tasks = realm.objects(Task.self).filter("synced = false")
            if(tasks.count>0){
                let para:NSMutableDictionary = NSMutableDictionary()
                let tkArray:NSMutableArray = NSMutableArray()
                
                para.setValue(user, forKey: "eMail")
                para.setValue(keychainPassword, forKey: "password")
                para.setValue("911430509678238", forKey: "mobileIMEINumber")
           
                for task in tasks
                {
                    let tk: NSMutableDictionary = NSMutableDictionary()
                    
                    
                    tk.setValue(task.incrementID(), forKey: "taskIDFrmMobile")
                    tk.setValue(task.taskID, forKey: "taskID")
                    tk.setValue(task.accountID, forKey: "accountID")
                    tk.setValue(task.taskDescription, forKey: "taskDescription")
                    tk.setValue(task.dueDate, forKey: "dueDate")
                    tk.setValue(task.dueTime, forKey: "dueTime")
                    tk.setValue(task.remindDate, forKey: "remindDate")
                    tk.setValue(task.remindTime, forKey: "remindTime")
                    tk.setValue(task.taskLat, forKey: "taskLat")
                    tk.setValue(task.taskLng, forKey: "taskLng")
                    tk.setValue(task.taskAddress, forKey: "taskAddress")
                    
//                    geocode(latitude: task.taskLat, longitude: task.taskLng) { address, error in
//                        guard let _ = address, error == nil else { return }
//
//
//                            tk.setValue(address, forKey: "taskAddress")
//
//
//                    }
                    tk.setValue(task.mapLocatedAddress, forKey: "mapLocatedAddress")
                    tk.setValue(task.sync, forKey: "sync")
                    tk.setValue(task.markedAsDone, forKey: "markedAsDone")
                    tk.setValue(task.createdDate, forKey: "createdDate")
                    tk.setValue(task.shortNotes, forKey: "shortNotes")
                    tk.setValue(task.snotesId, forKey: "snotesId")
                    tk.setValue(task.taskStatus, forKey: "taskStatus")
                    tk.setValue(task.TasktypeID, forKey: "TasktypeID")
                    tk.setValue(task.Others, forKey: "Others")
                    tk.setValue(task.SpecialColumnValue, forKey: "SpecialColumnValue")
                    tk.setValue(task.IsFavourite, forKey: "IsFavourite")
                    tk.setValue(task.TaskDifferentiation, forKey: "TaskDifferentiation")
                    tk.setValue(task.AutoGenFieldNo, forKey: "AutoGenFieldNo")
                    tk.setValue(task.ReferenceNo, forKey: "ReferenceNo")
                    tkArray.add(tk)
                }
                
                para.setObject(tkArray, forKey: "tasks" as NSCopying)
                let values : [String: Any] = para as! [String : Any]
                print(values)
                
                request.httpBody = try! JSONSerialization.data(withJSONObject: values)
           
                Alamofire.request(request)
                    .responseJSON { response in
                  
                        switch response.result {
                        case .failure(let error):
                            print(error)
                           
                            if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                                print(responseString)
                            }
                        case .success(let responseObject):
                            
                            print(responseObject)
                            self.updateRealm(data: tasks)
            
                       
                        }
                        
                }
            }
        }
    }
    func updateRealm(data: Results<Task>) {
        for task in data{
            try! realm.write {
                task.synced = true
            }

        }
    }
    
    func geocode(latitude: Double, longitude: Double, completion: @escaping (String?, Error?) -> ())  {
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude), completionHandler:
            {(placemarks, error) in
                    if (error != nil)
                    {
                        print("reverse geodcode fail: \(error!.localizedDescription)")
                    }
                    let pm = placemarks! as [CLPlacemark]
            
                    if pm.count > 0 {
                    let pm = placemarks![0]
                 
                    var addressString : String = ""
                    if pm.subLocality != nil {
                    addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                    addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                    addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                    addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                    addressString = addressString + pm.postalCode! + " "
                    }
            
            
                        print(addressString)
                    
                }
            })
        
            }
            
            
            
    
    }

