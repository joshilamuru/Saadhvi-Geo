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
    static let serviceName = "TouchMeIn"
    static let accessGroup: String? = nil
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    var passwordItems: [KeychainPasswordItem] = []
    let createLoginButtonTag = 0
    let loginButtonTag = 1

    @IBOutlet weak var userTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var userValidationLabel: UILabel!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    var authenticated = false
    let realm = try! Realm()
    var encryptedPassword = ""
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userTextfield.delegate = self
        self.passwordTextfield.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        setupView()
        //getting values in textviews
        
    
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
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
      
        if((validate(userTextfield).0) && (validate(passwordTextfield).0)){
            print("both are valid")
            
            
            SVProgressHUD.show()
            encryptedPassword = passwordTextfield.text!.md5()
            authenticateUser(username: userTextfield.text!, password: encryptedPassword) {
            (response) in
                if(self.authenticated){
                    //store in keychain
                     UserDefaults.standard.setValue(self.userTextfield.text, forKey: "username")
                    do {
                        
                        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                                account: self.userTextfield.text!,
                                                                accessGroup: KeychainConfiguration.accessGroup)
                        
                        // Save the password for the user
                        try passwordItem.savePassword(self.encryptedPassword)
                    } catch {
                        fatalError("Error updating keychain - \(error)")
                    }
                    //get the tasktypes and accounts from server
                      self.loadTaskTypefromServer(username: self.userTextfield.text!, password: self.encryptedPassword)
                    self.loadPOIfromServer(username: self.userTextfield.text!, password: self.encryptedPassword)
                  
                }
            }
        }else
        {
            UIView.animate(withDuration: 0.25, animations: {
                self.passwordValidationLabel.isHidden = false
            })
            self.passwordValidationLabel.text = "Check your email and password"
            print("Input not correct")
            
        }
        
    }
    
    func loadTaskTypefromServer(username: String, password: String) -> Void {
        let url = Constants.Domains.Stag + Constants.syncTaskTypes
        let input : [String: Any] = [ "TaskTypeLUV": 0,
                                      "CustomFieldLUV": 0,
                                      "FormFieldLUV": 0,
                                      "FormTypeLUV": 0,
                                      "FormTaskTypeLUV": 0,
                                      "eMail": username,
                                      "mobileIMEINumber": "911430509678238",
                                      "password": password]
        Alamofire.request(url, method: .post, parameters: input, encoding: JSONEncoding.default, headers: nil).responseJSON
            {
                (response) in
                
                print(response.request as Any)
                print(response.response as Any)
                print(response.result.value as Any)
                
                if response.result.isSuccess{
                    //loadPOI in realm
                    
                    let result : JSON = JSON(response.result.value!)
                    
                    self.updateTaskTypesData(json: result)
                    
                    
                    self.updateCustomFieldData(json: result)
                   
                }
                
        }
    }
    func loadPOIfromServer(username: String, password: String) -> Void {
        //
        let url = Constants.Domains.Stag + Constants.requestPOI
       // let url = "http://49.207.180.189:8082/taskease/requestAT.htm"
        let input: [String: Any] = [ "TaskTypeLUV": 0,
                                     "CustomFieldLUV": 0,
                                     "FormFieldLUV": 0,
                                     "FormTypeLUV": 0,
                                     "FormTaskTypeLUV": 0,
                                     "eMail": username,
                                     "mobileIMEINumber": "911430509678238",
                                     "password": password]
      
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
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "loginPressedSegue", sender: self)
                }
                else {
                    print("Error \(response.result.error)")
                    
                    SVProgressHUD.dismiss()
                    
                }
                
                
        }
    }
    
    func updateTaskTypesData(json: JSON) {
        for item in json["tasktype"].arrayValue {
        print(item["TaskTypeID"].intValue)
            do{
                try realm.write{
                    let taskType = TaskType()
                    taskType.Desc = item["Desc"].stringValue
                    taskType.JobType = item["JobType"].stringValue
                    taskType.JobTypeID = item["JobTypeID"].intValue
                    taskType.OrganizationID = item["OrganizationID"].intValue
                    taskType.TaskTypeID = item["TaskTypeID"].stringValue
                    taskType.TypeName = item["TypeName"].stringValue
                    realm.add(taskType, update: true)
                }
            }catch{
                print("Error adding place to realm \(error)")
            }
            
            
        }
    }
    
    func updateCustomFieldData(json: JSON) {
        for item in json["customfield"].arrayValue {
            do{
                try realm.write{
                    let customField = CustomField()
                    customField.CFormFieldID = item["CFormFieldID"].stringValue
                    customField.Desc = item["Desc"].stringValue
                    customField.DisplayName = item["DisplayName"].stringValue
                    customField.EntryType = item["EntryType"].stringValue
                    customField.TaskTypeID = item["TaskTypeID"].stringValue
                    customField.DefaultValues = item["DefaultValues"].stringValue
                    
                    realm.add(customField, update: true)
                }
            }catch{
                print("Error adding place to realm \(error)")
            }
        }
    }
    func updatePOIData(json: JSON){
        
        let count : Int = json["totalCount"].intValue
     //   let count : Int = json["accountRead"].
        if(count > 0) {
        for i in 0..<count {
           
            do{
                try realm.write{
                    let newPlace = POI()
                    newPlace.accountID = json["accountRead"][i]["accountID"].stringValue
                    newPlace.TasktypeID = json["accountRead"][i]["TasktypeID"].intValue
                    newPlace.name = json["accountRead"][i]["accountName"].stringValue
                    newPlace.address = json["accountRead"][i]["taskAddress"].stringValue
                    newPlace.latitude = json["accountRead"][i]["taskLat"].doubleValue
                    newPlace.longitude = json["accountRead"][i]["taskLng"].doubleValue
                    newPlace.createdDate = json["accountRead"][i]["createdDate"].stringValue
                    newPlace.synced = true
                    realm.add(newPlace, update: true)
                  
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
        
        
        let url = Constants.Domains.Stag + Constants.authUserMethod
        //let url = "http://49.207.180.189:8082/taskease/authenticationUser.htm"
        //+ Constants.authUserMethod
        //{"eMail":"user2@taskease.com","password":"21232f297a57a5a743894a0e4a801fc3","mobileIMEINumber":"911430509678238","deviceID":"APA91bGIWYSx_ufY3fMVu0z1jk4U_LVvh-FdFhDJUrlZA0igkpJH0sJ-k9tRv11N24T9_-ccADRAKMCOldHKDdaIOD1WucuCX_AL9s_6_8-7PKMzDeSdo8MQql0EQDUnsMZ7E6TPlvfXZCrplk4U9DFL2oH2OyJEkw","mobileInfo":"VERSION.RELEASE-6.0,MODEL-Android SDK built for x86,TASKEASE_VERSION_NAME-Revamp 2.51.67","osType":"ANDROID"}
        
        //let encryptedPassword = MD5(string: password).toHexString()
        
        
        
        let message: [String: String] =
            ["eMail": username, "password": password, "mobileIMEINumber": "911430509678238", "deviceID":
                (UIDevice.current.identifierForVendor?.uuidString)!,"mobileInfo":UIDevice.current.systemVersion, "osType": "iOS" ]
    
       
        Alamofire.request(url, method: .post, parameters: message, encoding: JSONEncoding.default, headers: nil).responseJSON
             {
                (response) in
                
                        print(response.request as Any)
                        print(response.response as Any)
                        print(response.result.value as Any)
                
                    if response.result.isSuccess{
                        print("success - authenticated")
                        self.authenticated = true
                      //  SVProgressHUD.dismiss()
                        
                    }
                    else {
                        print("Error \(response.result.error)")
                        self.authenticated = false
                        SVProgressHUD.dismiss()
                        
                    }
                completion(self.authenticated)
             
        }
       
    }
    struct CustomEncoding: ParameterEncoding {
        func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
            var request = try! URLEncoding().encode(urlRequest, with: parameters)
            let urlString = request.url?.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "=")
            request.url = URL(string: urlString!)
            return request
        }
    }
    
    
    
    @IBAction func userEditingDidChange(_ sender: UITextField) {
        userValidationLabel.isHidden = true
        passwordValidationLabel.isHidden = true
        switch sender {
            
        case userTextfield:
            let (validuser, messageuser) = validate(userTextfield)
            
            if(validuser){
                passwordTextfield.becomeFirstResponder()
                
            }
            
            self.userValidationLabel.text = messageuser
            
            UIView.animate(withDuration: 0.25, animations: {
                self.userValidationLabel.isHidden = validuser
            })
            
            
        case passwordTextfield:
            // Validate Text Field
            let (valid, message) = validate(passwordTextfield)
            if(valid){
                passwordTextfield.resignFirstResponder()
            }
            // Update Password Validation Label
            self.passwordValidationLabel.text = message
            
            // Show/Hide Password Validation Label
            UIView.animate(withDuration: 0.25, animations: {
                self.passwordValidationLabel.isHidden = valid
            })
        default:
         //   passwordTextfield.resignFirstResponder()
            userTextfield.becomeFirstResponder()
        }
        
    }
    
    
    fileprivate func validate(_ textField: UITextField) ->(Bool, String?) {
        
        guard let text = textField.text else {
            return (false, nil)
        }
        if(textField == userTextfield) {
            if(!isValidEmail(textField.text!)){
                return (false, "Invalid email" )
            }
        }
        return (text.count > 0, "This field cannot be empty.")
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
    
    
  
}


