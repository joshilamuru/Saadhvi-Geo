//
//  TaskType.swift
//  sampleForGeo
//
//  Created by saadhvi on 8/1/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import Foundation
import RealmSwift

class TaskType: Object {
    
    @objc dynamic var TaskTypeIDFrmMobile: String = UUID().uuidString
    @objc dynamic var OrganizationID : Int = 0
    @objc dynamic var Desc : String = ""
    @objc dynamic var TypeName : String = ""
    @objc dynamic var JobTypeID : Int = 0
    @objc dynamic var JobType : String = ""
    @objc dynamic var TaskID: String = ""
    @objc dynamic var TaskLat: Double = 0.0
    @objc dynamic var TaskLng: Double = 0.0
    @objc dynamic var TaskAddress: String = ""
    @objc dynamic var mapLocatedAddress: String = ""
    @objc dynamic var sync: String = ""
    @objc dynamic var markedAsDone: Int = 0
    @objc dynamic var createdDate: String = ""
    @objc dynamic var shortNotes:String = ""
    @objc dynamic var snotesId: Int = 0
    @objc dynamic var taskStatus:String = ""
    @objc dynamic var TasktypeID:Int = 0
    @objc dynamic var SpecialColumnValue: String = ""
    @objc dynamic var IsFavourite:Int = 0
    @objc dynamic var TaskDifferentiation: String = ""
    @objc dynamic var AutoGenFieldNo: String = ""
    @objc dynamic var ReferenceNo: String = ""
     @objc dynamic var synced : Bool = false
    @objc dynamic var taskIDToServer: Int = 0
    
    override static func primaryKey() -> String? {
        return "TaskTypeIDFrmMobile"
    }
    
    func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(POI.self).max(ofProperty: "taskIDToServer") as Int? ?? 0) + 1
    }
    
   
}


