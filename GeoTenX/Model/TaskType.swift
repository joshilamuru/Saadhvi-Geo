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
    
    @objc dynamic var TaskTypeID: String = UUID().uuidString
    @objc dynamic var OrganizationID : Int = 0
    @objc dynamic var Desc : String = ""
    @objc dynamic var TypeName : String = ""
    @objc dynamic var JobTypeID : Int = 0
    @objc dynamic var JobType : String = ""
     @objc dynamic var synced : Bool = false
    
    
    override static func primaryKey() -> String? {
        return "TaskTypeID"
    }
    
    
    
   
}


