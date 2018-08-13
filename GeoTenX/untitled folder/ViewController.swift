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

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var userTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var userValidationLabel: UILabel!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            //adding background image to view
           // let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
          //  backgroundImage.image = UIImage(named: "bkgimage.jpg")
          //  backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        //self.view.insertSubview(backgroundImage, at: 0)
            self.userTextfield.delegate = self
            self.passwordTextfield.delegate = self
            setupView()
            //getting values in textviews
        
        
        
    }
    fileprivate func setupView() {
        userValidationLabel.isHidden = true
        // Configure Password Validation Label
        passwordValidationLabel.isHidden = true
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logInPressed(_ sender: Any) {
        if((validate(userTextfield).0) && (validate(passwordTextfield).0)){
            print("both are valid")
            if(authenticateUser(username: userTextfield.text!, password: passwordTextfield.text!)) {
            self.performSegue(withIdentifier: "loginPressedSegue", sender: self)
            }
        }else
        {
        print("Input not correct")
        
        }
        
    }
    
    func authenticateUser(username: String, password: String) ->Bool {
        let url = Constants.Domains.Production
            //+ Constants.authUserMethod
        //{"eMail":"user2@taskease.com","password":"21232f297a57a5a743894a0e4a801fc3","mobileIMEINumber":"911430509678238","deviceID":"APA91bGIWYSx_ufY3fMVu0z1jk4U_LVvh-FdFhDJUrlZA0igkpJH0sJ-k9tRv11N24T9_-ccADRAKMCOldHKDdaIOD1WucuCX_AL9s_6_8-7PKMzDeSdo8MQql0EQDUnsMZ7E6TPlvfXZCrplk4U9DFL2oH2OyJEkw","mobileInfo":"VERSION.RELEASE-6.0,MODEL-Android SDK built for x86,TASKEASE_VERSION_NAME-Revamp 2.51.67","osType":"ANDROID"}
        
//let encryptedPassword = MD5(string: password).toHexString()
        
        let encryptedPassword = password.md5()
        let parameters: [String: String] =
            ["eMail": username, "password": encryptedPassword, "mobileIMEINumber": "NA", "deviceID":
            (UIDevice.current.identifierForVendor?.uuidString)!,"mobileInfo":UIDevice.current.systemVersion, "osType": "iOS" ]
    
        Alamofire.request(url , method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                print(response.request as Any)
                print(response.response as Any)
                print(response.result.value as Any)
                if response.result.isSuccess {
                    
                }
                else {
                    
                }
        }

        return true
    }
    struct CustomEncoding: ParameterEncoding {
        func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
            var request = try! URLEncoding().encode(urlRequest, with: parameters)
            let urlString = request.url?.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "=")
            request.url = URL(string: urlString!)
            return request
        }
    }

    
/*func MD5(string: String) -> Data {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData
    }*/
   
    
   
    
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case userTextfield:
            
            
             let (validuser, messageuser) = validate(textField)
            
             if(validuser){
            passwordTextfield.becomeFirstResponder()
            
            }
            
            self.userValidationLabel.text = messageuser
            
             UIView.animate(withDuration: 0.25, animations: {
                self.userValidationLabel.isHidden = validuser
             })
            

        case passwordTextfield:
            // Validate Text Field
            let (valid, message) = validate(textField)
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
            passwordTextfield.resignFirstResponder()
        }
        
        return true
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

