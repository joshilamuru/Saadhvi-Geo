
//  Created by saadhvi on 8/10/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift
import Reachability

class SyncAcctToServer : NSObject {
    static let SharedSyncInstance = SyncAcctToServer()
    let realm = try! Realm()
    
    //declare this inside of viewWillAppear
    override init() {
        super.init()
        
    }
    
    func syncData(){
        
        let urlstring = Constants.Domains.Stag + Constants.createPOI
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
                
               // acct.setValue(place.accountID, forKey: "accountIDFrmMobile")
                acct.setValue(place.incrementID(), forKey: "accountIDFrmMobile")
                acct.setValue("0", forKey: "accountID")
                acct.setValue(place.name, forKey: "accountName")
                acct.setValue(place.name, forKey: "AccountDescription")
              //  acct.setValue("0", forKey: "dueDate")
               // acct.setValue("0", forKey: "dueTime")
             //   acct.setValue("0", forKey: "remindDate")
              //  acct.setValue("0", forKey: "remindTime")
                acct.setValue(place.latitude, forKey: "AccountLat")
                acct.setValue(place.longitude, forKey: "AccountLng")
                acct.setValue(place.address, forKey: "AccountAddress")
                acct.setValue("Synched", forKey: "sync")
               // acct.setValue(0, forKey: "markedAsDone")
                acct.setValue(place.createdDate, forKey: "createdDate")
             //   acct.setValue("", forKey: "shortNotes")
              //  acct.setValue(0, forKey: "snotesId")
              //  acct.setValue("", forKey: "taskStatus")
                acct.setValue(place.AccountTypeID, forKey: "AccountTypeID")
                acct.setValue("{}", forKey: "Others")
             //   acct.setValue("", forKey: "SpecialColumnValue")
                acct.setValue(0, forKey: "IsFavourite")
                acct.setValue("M", forKey: "AccountDifferentiation")
              //  acct.setValue("", forKey: "AutoGenFieldNo")
              //  acct.setValue("", forKey: "ReferenceNo")
                acctArray.add(acct)
            }
            
            para.setObject(acctArray, forKey: "accounts" as NSCopying)
            let values : [String: Any] = para as! [String : Any]
            
            print("values send: \(values)")
            
            request.httpBody = try! JSONSerialization.data(withJSONObject: values)
            
            print("request body: \(request.httpBody!)")
         
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
                           print(NSString(data: (response.request?.httpBody)!, encoding: String.Encoding.utf8.rawValue))
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
