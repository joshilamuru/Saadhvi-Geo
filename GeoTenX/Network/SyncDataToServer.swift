
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
            
            let TTs = realm.objects(TaskType.self).filter("synced = false")
            if(TTs.count>0){
                let para:NSMutableDictionary = NSMutableDictionary()
                let acctArray:NSMutableArray = NSMutableArray()
                
                para.setValue(user, forKey: "eMail")
                para.setValue(keychainPassword, forKey: "password")
                para.setValue("911430509678238", forKey: "mobileIMEINumber")
                /*{"taskIDFrmMobile":9,"taskID":"504451","accountID":"90","taskDescription":"ssssssss","dueDate":"25-Jan-1900","dueTime":"08:00 AM","remindDate":"25-Jan-1900","remindTime":"07:00 AM","taskLat":0,"taskLng":0,"taskAddress":"","mapLocatedAddress":"","sync":"Synched","markedAsDone":0,"createdDate":"13-08-2018 18:36:14","shortNotes":"","snotesId":0,"taskStatus":"Open","TasktypeID":310,"Others":"{\"TSL\":{\"ST\":\"20180813 183614\",\"Lat\":\"13.039103231269072\",\"Lng\":\"80.17174715475144\",\"AL\":\"75.089554\",\"LP\":\"network\",\"cellId\":2147483647,\"lacId\":2147483647},\"TUL\":{\"UT\":\"20180813 184058\",\"Lat\":\"13.039103231269072\",\"Lng\":\"80.17174715475144\",\"AL\":\"75.08279\",\"LP\":\"network\",\"cellId\":2147483647,\"lacId\":2147483647}}","SpecialColumnValue":"","IsFavourite":0,"TaskDifferentiation":"M","AutoGenFieldNo":"","ReferenceNo":"72737337"}*/
                for tt in TTs
                {
                    let acct: NSMutableDictionary = NSMutableDictionary()
                    
                    acct.setValue(tt.TaskTypeIDFrmMobile, forKey: "taskIDFrmMobile")
                    acct.setValue(tt.JobTypeID, forKey: "taskID")
                    acct.setValue("0", forKey: "accountID")
                    acct.setValue(tt.Desc, forKey: "taskDescription")
                    acct.setValue("0", forKey: "dueDate")
                    acct.setValue("0", forKey: "dueTime")
                    acct.setValue("0", forKey: "remindDate")
                    acct.setValue("0", forKey: "remindTime")
                    acct.setValue(tt.TaskLat, forKey: "taskLat")
                    acct.setValue(tt.TaskLng
                        , forKey: "taskLng")
                    acct.setValue(tt.TaskAddress, forKey: "taskAddress")
                    acct.setValue("0", forKey: "mapLocatedAddress")
                    acct.setValue("0", forKey: "sync")
                    acct.setValue("0", forKey: "markedAsDone")
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
                }
                
                para.setObject(acctArray, forKey: "accounts" as NSCopying)
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
                            self.updateRealm(data: TTs)
                        }
                        
                }
            }
        }
    }
    func updateRealm(data: Results<TaskType>) {
        for taskType in data{
            try! realm.write {
                taskType.synced = true
            }
            
        }
    }
}
