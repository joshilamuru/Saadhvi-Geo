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
    @objc dynamic var sync: String = ""
    @objc dynamic var markedAsDone: Int = 0
    @objc dynamic var LastUpdatedValue: Int = 0
    @objc dynamic var TasktypeID:Int = 0
    @objc dynamic var SpecialColumnName: String = ""
    @objc dynamic var organisationName: String = ""
    @objc dynamic var IsAutoGenField: Int = 0
    @objc dynamic var IsReferenceField: Int = 0
     @objc dynamic var synced : Bool = false
    @objc dynamic var taskIDToServer: Int = 0
    @objc dynamic var AccountTypeID: Int = 0
    
    override static func primaryKey() -> String? {
        return "TaskTypeIDFrmMobile"
    }
    
    func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(TaskType.self).max(ofProperty: "taskIDToServer") as Int? ?? 0) + 1
    }
    
   
}


