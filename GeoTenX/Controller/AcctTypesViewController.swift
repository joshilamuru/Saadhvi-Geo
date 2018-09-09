//
//  AcctTypesViewController.swift
//  GeoTenX
//
//  Created by saadhvi on 9/6/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import RealmSwift
import CoreLocation
class AcctTypesViewController: UITableViewController {
     var currentLocation = CLLocation()
    var acctTypes: Results<AccountType>!
    var selectedIndex: Int!
    override func viewDidLoad() {
        super.viewDidLoad()

        acctTypes = getAcctTypes()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getAcctTypes() ->Results<AccountType>{
        
            let realm = try! Realm()
            let types = realm.objects(AccountType.self)
            print(types)
            return types
        }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return acctTypes.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "addPlaceSegue", sender: self)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        selectedIndex = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath)
        cell.textLabel?.text = "Create " + acctTypes[indexPath.row].TypeName
        return cell
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = NSLocalizedString("Account Types", comment: "Account Types")
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addPlaceSegue") {
            let destinationVC = segue.destination as! NewPlaceViewController
            destinationVC.currentLocation = (currentLocation)
            destinationVC.acctTypeID = acctTypes[selectedIndex].AccountTypeID
            navigationItem.title = " "
            destinationVC.navigationItem.title = NSLocalizedString("Add A New Place", comment: "Add A New Place")
        }
    }
}
