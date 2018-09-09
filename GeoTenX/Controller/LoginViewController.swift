//
//  ViewController.swift
//  sampleForGeo
//
//  Created by saadhvi on 6/13/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import UIKit
import CryptoSwift
import Alamofire
import SwiftyJSON
import SVProgressHUD
import RealmSwift

struct KeychainConfiguration {
    static let serviceName = "SerName"
    static let accessGroup: String? = nil
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    var json: JSON = JSON.null
    let userDefault = UserDefaults.standard
    var passwordItems: [KeychainPasswordItem] = []
    let createLoginButtonTag = 0
    let loginButtonTag = 1
    
    @IBOutlet weak var userTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var LoginBtn: UIButton!
    @IBOutlet weak var userValidationLabel: UILabel!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    var authenticated = false
    let realm = try! Realm()
    
    var encryptedPassword = ""
    //let myGroup = DispatchGroup()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        //if already logged in ??
        self.userTextfield.delegate = self
        self.passwordTextfield.delegate = self
         userTextfield.placeholder = NSLocalizedString("Username", comment: "Enter username")
        passwordTextfield.placeholder = NSLocalizedString("Password", comment: "Enter password")
        LoginBtn.setTitle(NSLocalizedString("Login", comment: "Login"), for: .normal)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        setupView()
        //getting values in textviews
        userTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //autologin if user logged in the device
                if (userDefault.bool(forKey: "isLoggedIn")){
                    print("user logged in")
                  self.performSegue(withIdentifier: "loginPressedSegue", sender: self)
                }else{
                    print("no user logged in")
                  
                }
        }

        
    @objc func keyboardWillChange(notification: Notification){
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        if notification.name == NSNotification.Name.UIKeyboardWillShow ||
        notification.name == NSNotification.Name.UIKeyboardWillChangeFrame {
            view.frame.origin.y = -keyboardRect.height
        }else {
        view.frame.origin.y = 0
        }
    }
    fileprivate func setupView() {
        userValidationLabel.isHidden = true
        passwordValidationLabel.isHidden = true
    }
    func hideKeyboard(){
        userTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logInPressed(_ sender: Any) {
        dismissKeyboard()
        SVProgressHUD.show()
        let user = userTextfield.text
        if(NetworkManager.sharedInstance.reachability.connection != .none) {
        if((validate(textField: userTextfield).0) && (validate(textField: passwordTextfield).0)){
            print("both are valid")
            
           encryptedPassword = passwordTextfield.text!.md5()
            //**commenting for debugging--**//
           // encryptedPassword = "21232f297a57a5a743894a0e4a801fc3"
            authenticateUser(username: user!, password: encryptedPassword) {
            (response) in
                if(self.authenticated){
                    //store in keychain
                    
                    self.userDefault.setValue(user, forKey: "username")
                    //**commenting for debugging--**//
                   // self.userDefault.setValue("dig006@thetaskease.com", forKey: "username")
                    do {
                        
                        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                                account: user!,
                                                                accessGroup: KeychainConfiguration.accessGroup)
                        
                        // Save the password for the user
                        try passwordItem.savePassword(self.encryptedPassword)
                        self.userDefault.setValue(true, forKey: "isLoggedIn")
                        
                        
                    } catch {
                        self.userDefault.setValue(false, forKey: "isLoggedIn")
                        fatalError("Error updating keychain - \(error)")
                    }
                    DispatchQueue.main.async {
                    //get the tasktypes and accounts from server
                        self.loadPOIfromServer(username: user!, password: self.encryptedPassword)
                         self.loadAccountTypefromServer(username: user!, password: self.encryptedPassword)
                        self.loadTaskTypefromServer(username: user!, password: self.encryptedPassword)
                       
                    }
                }
                    else{
                    //show alert message - Invalid username/password
                  //  self.showAlertMessage(message: "Invalid username/password")
                    SVProgressHUD.dismiss()
                    self.userDefault.setValue(false, forKey: "isLoggedIn")
                    }
            }
        }else
        {
            SVProgressHUD.dismiss()
            self.passwordValidationLabel.text = NSLocalizedString("Check your email and password", comment: "Check your email and password")
            UIView.animate(withDuration: 0.25, animations: {
                self.passwordValidationLabel.isHidden = false
            },completion: nil)
            print("Input not correct")
            
        }
        }else{
            SVProgressHUD.dismiss()
           // showAlertMessage(message: "No Internet connection. Please connect to internet and try again")
        }
        
    }
    
    func loadAccountTypefromServer(username: String, password: String) {
        let url = Constants.Domains.Stag + Constants.syncAcctTypes
        let input : [String: Any] = [ "AccountTypeLUV": 0,
                                      "CustomFieldLUV": 0,
                                      "FormFieldLUV": 0,
                                      "FormTypeLUV": 0,
                                      "FormAccountTypeLUV": 0,
                                      "eMail": username,
                                      "mobileIMEINumber": "911430509678238",
                                      "password": password]
        
        SVProgressHUD.setStatus("Loading account types and custom fields...")
        
        Alamofire.request(url, method: .post, parameters: input, encoding: JSONEncoding.default, headers: nil).responseJSON
            {
                (response) in
                
                print(response.request as Any)
                print(response.response as Any)
                print(response.result.value as Any)
                
                if response.result.isSuccess{
                    //loadPOI in realm
                    
                    let result : JSON = JSON(response.result.value!)
                    //carrying out the update task in the background
                    // DispatchQueue.global(qos: .background).async(){
                    self.updateAccountTypesData(json: result)
                    
                    self.updateAccountTypeCustomFieldData(json: result)
                    //   }
               //     SVProgressHUD.dismiss()
                    
                    
                }else{
                    let formatMessage = NSLocalizedString("Unable to load account types and customfields", comment: "Unable to load tasktypes and customfields")
                    SVProgressHUD.dismiss()
                    self.showAlertMessage(message: formatMessage)
                }
                
        }
        
        
    }
    
    func updateAccountTypesData(json: JSON){
        for item in json["accounttype"].arrayValue {
            print(item["AccountTypeID"].intValue)
            
            do{
                let backgdRealm = try! Realm()
                //   let objects = backgndRealm.objects(TaskType.self)
                try backgdRealm.write{
                    let accountType = AccountType()
                    accountType.AccountTypeID = item["AccountTypeID"].stringValue
                    accountType.Desc = item["Desc"].stringValue
                    accountType.OrganizationID = item["OrganizationID"].intValue
                    accountType.TypeName = item["TypeName"].stringValue
                    backgdRealm.add(accountType, update: true)
                }
            }catch{
                print("Error updating tasktypes to realm \(error)")
            }
        }
    }
    
    func updateAccountTypeCustomFieldData(json: JSON){
        for item in json["customfield"].arrayValue {
            
            do{
                let backgdRealm = try! Realm()
                try backgdRealm.write{
                    //try self.realm.write{
                    let atcustomField = AccountTypeCustomField()
                    atcustomField.ATCFormFieldID = item["CFormFieldID"].stringValue
                    atcustomField.Desc = item["Desc"].stringValue
                    atcustomField.DisplayName = item["DisplayName"].stringValue
                    atcustomField.EntryType = item["EntryType"].stringValue
                    atcustomField.AccountTypeID = item["AccountTypeID"].stringValue
                    atcustomField.DefaultValues = item["DefaultValues"].stringValue
                    atcustomField.FieldName = item["FieldName"].stringValue
                    
                    backgdRealm.add(atcustomField, update: true)
                }
            }catch{
                print("Error adding customfields to realm \(error)")
            }
        }
    }
    
    func loadTaskTypefromServer(username: String, password: String) {
        let url = Constants.Domains.Stag + Constants.syncTaskTypes
        let input : [String: Any] = [ "TaskTypeLUV": 0,
                                      "CustomFieldLUV": 0,
                                      "FormFieldLUV": 0,
                                      "FormTypeLUV": 0,
                                      "FormTaskTypeLUV": 0,
                                      "eMail": username,
                                      "mobileIMEINumber": "911430509678238",
                                      "password": password]
        
        SVProgressHUD.setStatus("Loading task types and custom fields...")
    
            Alamofire.request(url, method: .post, parameters: input, encoding: JSONEncoding.default, headers: nil).responseJSON
                {
                    (response) in
                    
                    print(response.request as Any)
                    print(response.response as Any)
                    print(response.result.value as Any)
                    
                    if response.result.isSuccess{
                        //loadPOI in realm
                        
                        let result : JSON = JSON(response.result.value!)
                        //carrying out the update task in the background
                       // DispatchQueue.global(qos: .background).async(){
                            self.updateTaskTypesData(json: result)
                            
                            self.updateCustomFieldData(json: result)
                     //   }
                        SVProgressHUD.dismiss()
                        self.performSegue(withIdentifier: "loginPressedSegue", sender: self)
                        
                    }else{
                        let formatMessage = NSLocalizedString("Unable to load tasktypes and customfields", comment: "Unable to load tasktypes and customfields")
                        SVProgressHUD.dismiss()
                        self.showAlertMessage(message: formatMessage)
                    }
                    
            }
        
        
    }
    
    func loadPOIfromServer(username: String, password: String) {
        let url = Constants.Domains.Stag + Constants.requestPOI
        // let url = "http://49.207.180.189:8082/taskease/requestAT.htm"
        let input: [String: Any] = [ "AccountTypeLUV": 0,
                                     "CustomFieldLUV": 0,
                                     "FormFieldLUV": 0,
                                     "FormTypeLUV": 0,
                                     "FormAccountTypeLUV": 0,
                                     "eMail": username,
                                     "mobileIMEINumber": "911430509678238",
                                     "password": password]
        let formatMes = NSLocalizedString("Loading places...", comment: "Loading places...")
        SVProgressHUD.setStatus(formatMes)
      
            
        
        Alamofire.request(url, method: .post, parameters: input, encoding: JSONEncoding.default, headers: nil).responseJSON
            {
                (response) in
                
                print(response.request as Any)
                print(response.response as Any)
                print(response.result.value as Any)
                
                if response.result.isSuccess{
                    //loadPOI in realm
                    
                    let acctsJSON : JSON = JSON(response.result.value!)
                    
                    self.updatePOIData(json: acctsJSON)
                   
                  
                }
                else {
                    print("Error in requestAT \(response.result.error as Optional)")
                    
                    SVProgressHUD.dismiss()
                   
                }
                
                
         }
        
    }
    
 
    func updateTaskTypesData(json: JSON) {
     // DispatchQueue.global(qos: .background).async(){
            for item in json["tasktype"].arrayValue {
            print(item["TaskTypeID"].intValue)
           
                do{
                    let backgdRealm = try! Realm()
                 //   let objects = backgndRealm.objects(TaskType.self)
                     try backgdRealm.write{
                        let taskType = TaskType()
                        taskType.AccountTypeID = item["AccountTypeID"].intValue
                        taskType.Desc = item["Desc"].stringValue
                        taskType.JobType = item["JobType"].stringValue
                        taskType.JobTypeID = item["JobTypeID"].intValue
                        taskType.OrganizationID = item["OrganizationID"].intValue
                        taskType.TasktypeID = item["TaskTypeID"].intValue
                        taskType.TypeName = item["TypeName"].stringValue
                        backgdRealm.add(taskType, update: true)
                    }
                }catch{
                    print("Error updating tasktypes to realm \(error)")
                }
            }
        
      //  }
     
    }
    
    func updateCustomFieldData(json: JSON) {
     //DispatchQueue.global(qos: .background).async(){
        for item in json["customfield"].arrayValue {
            
            do{
                    let backgdRealm = try! Realm()
                    try backgdRealm.write{
                    //try self.realm.write{
                    let customField = CustomField()
                    customField.CFormFieldID = item["CFormFieldID"].stringValue
                    customField.Desc = item["Desc"].stringValue
                    customField.DisplayName = item["DisplayName"].stringValue
                    customField.EntryType = item["EntryType"].stringValue
                    customField.TaskTypeID = item["TaskTypeID"].stringValue
                    customField.DefaultValues = item["DefaultValues"].stringValue
                    customField.FieldName = item["FieldName"].stringValue
                        
                    backgdRealm.add(customField, update: true)
                }
            }catch{
                print("Error adding customfields to realm \(error)")
            }
        }
     //}
       
    }
    func updatePOIData(json: JSON){
        //deleting existing objects from realm that have come from server to prevent duplication as they don't have a primary key associated
       let existingObjsFrmServer = realm.objects(POI.self).filter("fromServer = true")
        if existingObjsFrmServer.count > 0{
            try! realm.write {
                realm.delete(existingObjsFrmServer)
                }
        }
 
        let count : Int = json["totalCount"].intValue
       
        if(count > 0) {
        for i in 0..<count {
           
            do{
                try realm.write{
                    let newPlace = POI()
                    newPlace.accountID = json["accountRead"][i]["accountID"].intValue
                    newPlace.AccountTypeID = json["accountRead"][i]["AccountTypeID"].intValue
                    newPlace.name = json["accountRead"][i]["accountName"].stringValue
                    newPlace.address = json["accountRead"][i]["accountAddress"].stringValue
                    newPlace.latitude = json["accountRead"][i]["accountLat"].doubleValue
                    newPlace.longitude = json["accountRead"][i]["accountLng"].doubleValue
                    newPlace.createdDate = json["accountRead"][i]["createdDate"].stringValue
                    newPlace.AccountDescription = json["accountRead"][i]["AccountDescription"].stringValue
                    newPlace.status = json["accountRead"][i]["status"].stringValue
                    newPlace.Others = json["accountRead"][i]["Others"].stringValue
                    newPlace.synced = true
                    newPlace.fromServer = true
                    realm.add(newPlace, update: true)
                    print("Others: \(newPlace.Others)")
                  //  print("Successful in getting account \(i) from server")
                   // print (json["accountRead"][i])
                }
            }catch{
                print("Error adding place to realm \(error)")
            }
        }
       //
        
        }else {
            print("error getting data")
        }
        
        
       
       
    }
    func authenticateUser(username: String, password: String, completion: @escaping (Bool) -> Void) {
        let formatStr = NSLocalizedString("Authenticating user...", comment: "Authenticating user...")
        SVProgressHUD.setStatus(formatStr)
        let url = Constants.Domains.Stag + Constants.authUserMethod
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            print(uuid)
            
        }
        
        let message: [String: String] =
            ["eMail": username, "password": password, "mobileIMEINumber": "911430509678238", "deviceID":
                (UIDevice.current.identifierForVendor?.uuidString)!,"mobileInfo":UIDevice.current.systemVersion, "osType": "iOS" ]
    
       
        Alamofire.request(url, method: .post, parameters: message, encoding: JSONEncoding.default, headers: nil).responseJSON
             { response in
                if let result = response.result.value as? String {
                    if(result == "Login-Failure"){
                        self.authenticated = false
                        SVProgressHUD.dismiss()
                        let messageStr = NSLocalizedString("Invalid username or password", comment: "Invalid username or password")
                        self.showAlertMessage(message: messageStr)
                       // print("Error \(response.result.error!)")
                        
                    }
                }else if let resultDic = response.result.value as? [String: Any]{
                        let json = JSON(resultDic)
                        print("Json: \(json["message"])")
                            if json["message"].stringValue == "IMEI-Invalid-Failure"{
                                self.authenticated = false
                                SVProgressHUD.dismiss()
                                self.showAlertMessage(message: "Invalid IMEI")
                                
                            }else {
                                if json["message"].stringValue == "IMEI-valid-Success"{
                                self.authenticated = true
                            }
                    }
                }else {
                    SVProgressHUD.dismiss()
                    self.showAlertMessage(message: "Error connecting to server")
                }
                
                
               
          completion(self.authenticated)
        }
        
             
    }
  
    func showAlertMessage(message: String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.userValidationLabel.isHidden = true
        self.passwordValidationLabel.isHidden = true
    
    }

    
    fileprivate func validate(textField: UITextField) ->(Bool, String?) {
        
        guard textField.text != nil else {
            return (false, "This field cannot be empty.")
        }
        if(textField == userTextfield) {
            if(!isValidEmail(textField.text!)){
                return (false, "Invalid email" )
            }
        }
        if(textField.text?.count == 0){
            return (false, "This field cannot be empty.")
        }
        return (true, nil)
    }
    
    func isValidEmail(_ emailField: String) -> Bool {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
            "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: emailField)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
  
}


