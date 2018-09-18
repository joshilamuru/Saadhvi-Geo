//
//  TaskTypesViewController.swift
//  GeoTenX
//
//  Created by saadhvi on 9/9/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import RealmSwift
import CoreLocation

struct cellData {
    var opened = Bool()
    var title = String()
    var sectionData = [String]()
}
class TaskTypesViewController: UITableViewController {
    var currentLocation = CLLocation()
    var taskTypes: Results<TaskType>!
    var selectedIndex: Int!
    var poi: POI!
    var tasks: Results<Task>!
    var tableViewData = [cellData]()
    var sectionHeaderNames = [Int: String]()
    var selectedRowIndex: Int!
    var taskTypeName: String!
//    var isExpanded: Bool = true
//    var Section = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTaskTypeNames()
        tasks = getTasksforAcct(id: String(poi.accountID))
        
        print(tasks.count)
//        tableViewData = [cellData(opened: false, title: "Title1", sectionData: ["CELL1","cell2","cell3"]),
//                        cellData(opened: false, title: "Title2", sectionData: ["CELL1","cell2","cell3"]),
//                        cellData(opened: false, title: "Title3", sectionData: ["CELL1","cell2","cell3"])]
        for name in sectionHeaderNames {
            print(name.value)
            if(name.value != "") {
            tableViewData.append(cellData(opened: false, title: name.value, sectionData: getTasksforTaskType(id: name.key)))
            }
        }
     
        print(tasks)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    func loadTaskTypeNames() {
        let realm = try! Realm()
        taskTypes = realm.objects(TaskType.self)
        
        for type in taskTypes {
            sectionHeaderNames[type.TasktypeID] = type.TypeName
            
        }
        
    }
    func getTasksforTaskType(id: Int)->[String] {
        var taskList = [String]()
        for task in tasks {
            print(task.TasktypeID)
            if(task.TasktypeID == id){
                taskList.append(task.taskID)
            }
            
        }
        return taskList
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.isUserInteractionEnabled = true
        navigationItem.title = NSLocalizedString("Task Types", comment: "Task Types")
    }
    
    func getTasks(id: String) ->Results<Task> {
        let realm = try! Realm()
        let tasks = realm.objects(Task.self).filter("accountID == %@", id)
        
        print(tasks.count)
        return tasks
        
    }
    func getTaskTypes() ->Results<TaskType>{
        
        let realm = try! Realm()
        let types = realm.objects(TaskType.self)
       
        return types
    }
    func getTasksforAcct(id: String) ->Results<Task> {
        let realm = try! Realm()
        let tasks = realm.objects(Task.self).filter("accountID == %@", id)
        for task in tasks {
            print(task.TasktypeID)
        }
//        for task in tasks {
//            sectionHeaderNames[task.TasktypeID] = getTaskTypeName(id:task.TasktypeID)
//        }
//        print(sectionHeaderNames.count)
        return tasks
    }
    func getTaskTypeName(id:Int) -> String{
        
        let realm = try! Realm()
        let type = realm.objects(TaskType.self).filter("TasktypeID == %@", id)
        if let typeName = type.first?.TypeName{
            return typeName
        }else {
            return ""
        }
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewData[section].opened == true {
            return tableViewData[section].sectionData.count + 1
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      selectedIndex = indexPath.section
          taskTypeName = tableViewData[indexPath.section].title
//        let index = tableView.indexPathForSelectedRow!
//        let cell = tableView.cellForRow(at: index)!
//        taskTypeName = cell.textLabel?.text
     //   tableView.isUserInteractionEnabled = false
        if indexPath.row == 0 {
            //if no tasks in a tasktype
            
            if tableViewData[indexPath.section].opened == true {
                tableViewData[indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            } else {
                tableViewData[indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        }else {
            selectedRowIndex = indexPath.row
            print("selectedIndex in didselectrowin: \(selectedIndex)")
            performSegue(withIdentifier: "formSegue", sender: self)
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        selectedIndex = indexPath.row
        print("selectedIndex: \(selectedIndex)")
        if indexPath.row == 0 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {return UITableViewCell()}
            cell.textLabel?.text = tableViewData[indexPath.section].title
          //  cell.textLabel?.textColor = UIColor.orange
         //   cell.backgroundColor = UIColor.darkGray
            return cell
        }else {
       
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {return UITableViewCell()}
            cell.textLabel?.text = tableViewData[indexPath.section].sectionData[indexPath.row - 1]
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "formSegue") {
            let destinationVC = segue.destination as! DynamicFormViewController
            
            destinationVC.taskTypeName = taskTypeName
            //  destinationVC.acctTypeID = poi.AccountTypeID
            //hard coding the tasktypeid for checkin
            destinationVC.currentLocation = currentLocation
        
            let keys = sectionHeaderNames.keys
            for key in keys {
                if(sectionHeaderNames[key] == taskTypeName) {
                    destinationVC.taskTypeID = key
                    print(key)
                }
                
            }
           
            print(destinationVC.taskTypeID)
            destinationVC.task = tasks[selectedRowIndex - 1]
            print(destinationVC.task)
            navigationItem.title = " "
            destinationVC.navigationItem.title = "Form Details"
            destinationVC.poi = poi
        }
    }
}
