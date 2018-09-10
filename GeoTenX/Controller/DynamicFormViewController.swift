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

class DynamicFormViewController: FormViewController{
    
 var acct : String = ""
    var taskTypeID : Int!
   // var acctTypeID: Int!
    @IBOutlet weak var acctLabel: UILabel!
    var customFields: Results<CustomField>? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let str = NSLocalizedString("Check-In", comment: "Check-In")
        self.navigationItem.title = str
        acctLabel.text = acct
        customFields = getCustomFieldsByTaskID(ID: String(taskTypeID))
        if(!(customFields?.isEmpty)!){
            loadForm()
        }else{
            let str = NSLocalizedString("No custom fields available. Try again", comment: "No custom fields available. Try again")
            
            showAlertMessage(message: str)
        }
        }

    func loadForm() {
    
        let sectStr = NSLocalizedString("Account Info", comment: "Account Info")
        form +++ Section(sectStr)
        // let section = form.sectionBy(tag: "Account Info")
        for field in customFields! {
            switch(field.EntryType) {
            case "Text":
                
                self.form.last! <<< TextRow(){ row in
                    row.title = field.DisplayName
                    row.placeholder = field.Desc
                }
                
            case "Number":
                self.form.last! <<< IntRow(){ row in
                    row.title = field.DisplayName
                    row.placeholder = field.Desc
                    
                }
            case "Date","Time":
                self.form.last! <<< DateTimeRow(){ row in
                    row.title = field.DisplayName
                    
                }
            case "Image Upload":
                self.form.last! <<< ImageRow(){ row in
                    row.title = field.DisplayName
                    row.sourceTypes = .Camera
                    row.clearAction = .yes(style: .default)

                }
               
            case "Option", "Auto Text":
                self.form.last! <<< PushRow<String>(){
                    $0.title = field.DisplayName
                    let values = (field.DefaultValues).components(separatedBy: ",")
                    print("Values are: \(values)")
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
                    $0.title = field.DisplayName
                    let values = (field.DefaultValues).components(separatedBy: ",")
                    print("Values are: \(values)")
                    $0.options = values
                    $0.value = [""]
                    }.onPresent{from, to in
                        to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(DynamicFormViewController.multipleSelectorDone(_:)))
                        
                }
      
            case "Dual Camera":
                self.form.last! <<< PushRow<String>() {
                    $0.title = field.DisplayName
                    $0.presentationMode = .segueName(segueName: "DualCameraSegue", onDismiss: nil)
                }
//                    .onPresent { from, to in
//                        to.selectableRowCellUpdate = { cell, row in
//                            print("here")
//                                cell.
//                                cell.textLabel!.textColor = UIColor.green
//                        }
           //             }
                
                
                
                
                
                
            default:
                print("no custom fields - \(field.EntryType)")
                
            }
            
        }
        //        for section in form.allSections {
        //            print("Section tags - \(section.tag)")
        //        }
        self.form.last! <<< ButtonRow("Save") {
            
            $0.title = NSLocalizedString("Save", comment: "Save")
            }.cellUpdate { cell, row in
                cell.textLabel?.textColor = UIColor.orange
                cell.backgroundColor = UIColor.darkGray }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func multipleSelectorDone(_ item: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }

    func json(obj:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: obj, options: []) else {
            return nil
        }
        print(data)
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
    
   
}

