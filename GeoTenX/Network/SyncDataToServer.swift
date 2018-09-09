
//  Created by saadhvi on 8/10/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift
import Reachability

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
            let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .short, timeStyle: .full)
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //get accounts that are not synced from realm
            
            let tasks = realm.objects(Task.self).filter("synced = false")
            if(tasks.count>0){
                let para:NSMutableDictionary = NSMutableDictionary()
                let acctArray:NSMutableArray = NSMutableArray()
                
                para.setValue(user, forKey: "eMail")
                para.setValue(keychainPassword, forKey: "password")
                para.setValue("911430509678238", forKey: "mobileIMEINumber")
              
                
                for task in tasks
                {
                    let acct: NSMutableDictionary = NSMutableDictionary()
                    
                    
                    acct.setValue(task.incrementID(), forKey: "taskIDFrmMobile")
                    acct.setValue(task.taskID, forKey: "taskID")
                    acct.setValue(task.accountID, forKey: "accountID")
                    acct.setValue(task, forKey: "taskDescription")
                    acct.setValue(task.dueDate, forKey: "dueDate")
                    acct.setValue(task.dueTime, forKey: "dueTime")
                    acct.setValue(task.remindDate, forKey: "remindDate")
                    acct.setValue(task.remindTime, forKey: "remindTime")
                    acct.setValue(task.taskLat, forKey: "taskLat")
                    acct.setValue(task.taskLng, forKey: "taskLng")
                    acct.setValue(task.taskAddress, forKey: "taskAddress")
                    acct.setValue(task.mapLocatedAddress, forKey: "mapLocatedAddress")
                    acct.setValue(task.sync, forKey: "sync")
                    acct.setValue(task.markedAsDone, forKey: "markedAsDone")
                    acct.setValue(timestamp, forKey: "createdDate")
                    acct.setValue(task.shortNotes, forKey: "shortNotes")
                    acct.setValue(task.snotesId, forKey: "snotesId")
                    acct.setValue(task.taskStatus, forKey: "taskStatus")
                    acct.setValue(task.TasktypeID, forKey: "TasktypeID")
                    acct.setValue(task.Others, forKey: "Others")
                    acct.setValue(task.SpecialColumnValue, forKey: "SpecialColumnValue")
                    acct.setValue(task.IsFavourite, forKey: "IsFavourite")
                    acct.setValue(task.TaskDifferentiation, forKey: "TaskDifferentiation")
                    acct.setValue(task.AutoGenFieldNo, forKey: "AutoGenFieldNo")
                    acct.setValue(task.ReferenceNo, forKey: "ReferenceNo")
                    acctArray.add(acct)
                }
                
                para.setObject(acctArray, forKey: "tasks" as NSCopying)
                let values : [String: Any] = para as! [String : Any]
                
                
                
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
}
