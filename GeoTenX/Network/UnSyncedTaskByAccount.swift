//
//  SyncTaskByAccount.swift
//  GeoTenX
//
//  Created by saadhvi on 9/11/18.
//  Copyright © 2018 Joshila. All rights reserved.
//
import Foundation
import Alamofire
import RealmSwift
import Reachability
import SwiftyJSON

class UnSyncedTaskByAccount: NSObject {
    static let SharedInstance = UnSyncedTaskByAccount()
    let realm = try! Realm()
    
    //declare this inside of viewWillAppear
    override init() {
        super.init()
        
    }
    
    func getUnsyncedTask(id: Int, completion: @escaping (String) -> Void) {
        let url = Constants.Domains.Stag + Constants.unsyncTaskInfo
        var result: JSON!
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
                
                let input: [String: Any] = [ "accountID": id,
                                             "eMail": user,
                                             "mobileIMEINumber": "911430509678238",
                                             "password": keychainPassword]
                Alamofire.request(url, method: .post, parameters: input, encoding: JSONEncoding.default, headers: nil).responseJSON
                {
                        (response) in
                        
                        print(response.request as Any)
                        print(response.response as Any)
                        print(response.result.value as Any)
                        
                        if response.result.isSuccess{
                            //loadPOI in realm
                            
                            result = JSON(response.result.value!)
                            print(result)
                            self.updateInRealm(json: result)
                        }
                    completion("We finished")
                }
            }
        
    }
    
    func updateInRealm(json: JSON) {
        for item in json["taskRead"].arrayValue {
          
            
                do{
                    
                    
                    try realm.write{
                        let task = Task()
                        task.taskID = item["taskID"].stringValue
                        task.accountID = item["accountID"].stringValue
                        task.taskDescription = item["taskDescription"].stringValue
                        task.AutoGenFieldNo = item["AutoGenFieldNo"].stringValue
                        task.createdDate = item["createdDate"].stringValue
                        task.dueDate = item["dueDate"].stringValue
                        task.dueTime = item["dueTime"].stringValue
                        task.IsFavourite = item["IsFavourite"].intValue
                        task.mapLocatedAddress = item["mapLocatedAddress"].stringValue
                        task.markedAsDone = item["markedAsDone"].intValue
                        task.Others = item["Others"].stringValue
                        task.ReferenceNo = item["ReferenceNo"].stringValue
                        task.remindDate = item["remindDate"].stringValue
                        task.remindTime = item["remindTime"].stringValue
                        task.shortNotes = item["shortNotes"].stringValue
                        task.snotesId = item["snotesId"].intValue
                        task.SpecialColumnValue = item["SpecialColumnValue"].stringValue
                        task.sync = item["sync"].stringValue
                        task.TasktypeID = item["TasktypeID"].intValue
                        task.taskAddress = item["taskAddress"].stringValue
                        task.TaskDifferentiation = item["TaskDifferentiation"].stringValue
                        task.taskIDFrmMobile = item["taskIDFrmMobile"].stringValue
                        
                        task.taskLat = item["taskLat"].doubleValue
                        task.taskLng = item["taskLng"].doubleValue
                        task.taskStatus = item["taskStatus"].stringValue
                        realm.add(task, update: true)
                    }
                }catch{
                    print("Error updating tasks to realm \(error)")
                }
            
        }
    }
}
