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

class TaskTypesViewController: UITableViewController {
    var currentLocation = CLLocation()
    var taskTypes: Results<TaskType>!
    var selectedIndex: Int!
    var poi: POI!
    var tasks: Results<Task>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        super.viewDidLoad()
        
        taskTypes = getTaskTypes()
       // SyncTaskByAccount.SharedSyncInstance.syncTask(id: poi.accountID)
        tasks = getTasks(id: String(poi.accountID))
        print(tasks)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
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
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskTypes.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.isUserInteractionEnabled = false
        performSegue(withIdentifier: "formSegue", sender: self)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        selectedIndex = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Create " + taskTypes[indexPath.row].TypeName
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "formSegue") {
            let destinationVC = segue.destination as! DynamicFormViewController
            destinationVC.taskTypeName = taskTypes[selectedIndex].TypeName
            //  destinationVC.acctTypeID = poi.AccountTypeID
            //hard coding the tasktypeid for checkin
            destinationVC.currentLocation = currentLocation
            destinationVC.taskTypeID = taskTypes[selectedIndex].TasktypeID
            navigationItem.title = " "
            destinationVC.navigationItem.title = "Form Details"
            destinationVC.poi = poi
        }
    }
}
