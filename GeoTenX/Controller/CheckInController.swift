//
//  CheckInController.swift
//  sampleForGeo
//
//  Created by saadhvi on 6/26/18.
//  Copyright © 2018 Joshila. All rights reserved.
//



import UIKit
import RealmSwift

class chkListCell: UITableViewCell {
    
    @IBOutlet weak var listLabel: UILabel!
    @IBOutlet weak var listImage: UIImageView!
}

class CheckInController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var acctLabel: UILabel!
    var acct : String = ""
    var chkList = ["Comments", "Pictures", "Forms", "Category/Subcategories"]
    var imgList = ["comment", "photo", "comment", "category"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Check-In"
        acctLabel.text = acct
        acctLabel.textAlignment = .left
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return chkList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let cell = tableView.cellForRow(at: indexPath as IndexPath) as! chkListCell
        if cell.listLabel.text == "Comments" {
            performSegue(withIdentifier: "commentSegue", sender: self)
        }else if cell.listLabel.text == "Pictures" {
            performSegue(withIdentifier: "pictureSegue", sender: self)
        }else if cell.listLabel.text == "Forms" {
            performSegue(withIdentifier: "formSegue", sender: self)
        }else if cell.listLabel.text == "Category/Subcategories" {
                performSegue(withIdentifier: "categorySegue", sender: self)
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! chkListCell
        cell.listLabel.text = chkList[indexPath.row]
        cell.listImage.image = UIImage(named: imgList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
}
