//
//  Task.swift
//  GeoTenX
//
//  Created by saadhvi on 9/9/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import UIKit
import RealmSwift

class Task: Object {
    
    @objc dynamic var taskIDFrmMobile: String = UUID().uuidString
    @objc dynamic var taskID : String = ""
    @objc dynamic var accountID : String = ""
    @objc dynamic var taskDescription : String = ""
    @objc dynamic var dueDate : String = ""//format "25-Jan-1900"
    @objc dynamic var remindDate : String = ""//format "07:00 AM"
    @objc dynamic var dueTime : String = ""
    @objc dynamic var remindTime : String = ""
    @objc dynamic var taskLat : Double = 0.0
    @objc dynamic var taskLng : Double = 0.0
    @objc dynamic var taskAddress : String = ""
    @objc dynamic var mapLocatedAddress : String = ""
    @objc dynamic var sync : String = ""
    @objc dynamic var markedAsDone : Int = 0
    @objc dynamic var createdDate : String = ""
    @objc dynamic var shortNotes : String = ""
    @objc dynamic var snotesId : Int = 0
    @objc dynamic var taskStatus : String = ""
    @objc dynamic var TasktypeID : Int = 0
    @objc dynamic var Others : String = ""
    @objc dynamic var SpecialColumnValue : String = ""
    @objc dynamic var IsFavourite: Int = 0
    @objc dynamic var TaskDifferentiation: String = ""
    @objc dynamic var AutoGenFieldNo: String = ""
    @objc dynamic var ReferenceNo : String = ""
    @objc dynamic var synced : Bool = false
    @objc dynamic var taskIDToServer : Int = 0
    
    override static func primaryKey() -> String? {
        return "taskIDFrmMobile"
    }
    func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(Task.self).max(ofProperty: "taskIDToServer") as Int? ?? 0) + 1
    }
}
