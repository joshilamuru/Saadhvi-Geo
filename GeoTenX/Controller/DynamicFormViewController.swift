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

class DynamicFormViewController: FormViewController {
 var acct : String = ""
    var taskTypeID : Int!
    @IBOutlet weak var acctLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Check-In"
        acctLabel.text = acct
        let customFields = getCustomFieldsByTaskID(ID: String(taskTypeID))
        
        form +++ Section("Account Info")
       // let section = form.sectionBy(tag: "Account Info")
        for field in customFields {
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
//            case "Option", "Choice", "Auto Text":
//                self.form +++ SelectableSection<ListCheckRow<String>>(field.DisplayName, selectionType: .singleSelection(enableDeselection: true)){section in
//                    section.tag = field.DisplayName
//                }
//
//                let options = (field.DefaultValues).components(separatedBy: ",")
//                for item in options {
//                    form.last! <<< ListCheckRow<String>(item){ listRow in
//                        listRow.title = item
//                        listRow.selectableValue = item
//                        listRow.value = nil
//                    }
//                }
            case "Option", "Auto Text":
                self.form.last! <<< PushRow<String>(){
                    $0.title = field.DisplayName
                    let values = (field.DefaultValues).components(separatedBy: ",")
                    print("Values are: \(values)")
                    $0.options = values
                    $0.value = ""
                    $0.selectorTitle = "Choose an option"
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
                
                
            default:
                print("no custom fields - \(field.EntryType)")
                
            }
           
            }
//        for section in form.allSections {
//            print("Section tags - \(section.tag)")
//        }
            self.form.last! <<< ButtonRow("Save") {
                $0.title = "Save"
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

    func getCustomFieldsByTaskID(ID: String) -> Results<CustomField>{
        
        let realm = try! Realm()
      //  let fields = realm.objects(CustomField.self).filter("TaskTypeID == %@", ID)
        let fields = realm.objects(CustomField.self).filter("TaskTypeID == '59'")
        
        return fields
    }
    
}

