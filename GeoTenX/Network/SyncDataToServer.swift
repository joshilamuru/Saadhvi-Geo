
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
            
            let POIs = realm.objects(POI.self).filter("synced = false")
            if(POIs.count>0){
                let para:NSMutableDictionary = NSMutableDictionary()
                let acctArray:NSMutableArray = NSMutableArray()
                
                para.setValue(user, forKey: "eMail")
                para.setValue(keychainPassword, forKey: "password")
                para.setValue("911430509678238", forKey: "mobileIMEINumber")
                
                for place in POIs
                {
                    let acct: NSMutableDictionary = NSMutableDictionary()
                    acct.setValue(place.name, forKey: "name")
                    acct.setValue(place.accountID, forKey: "accountIDFrmMobile")
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
                            self.updateRealm(data: POIs)
                        }
                        
                }
            }
        }
    }
    func updateRealm(data: Results<POI>) {
        for poi in data{
            try! realm.write {
                poi.synced = true
            }
            
        }
    }
}
