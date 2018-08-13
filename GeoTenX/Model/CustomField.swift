//
//  CustomField.swift
//  sampleForGeo
//
//  Created by saadhvi on 8/1/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import Foundation
import RealmSwift

class CustomField : Object {
    
   @objc dynamic var CFormFieldID: String = UUID().uuidString
    @objc dynamic var TaskTypeID : String = ""
    @objc dynamic var DisplayName : String = ""
    @objc dynamic var Desc : String = ""
    @objc dynamic var EntryType : String = ""
    @objc dynamic var DefaultValues : String = ""
    @objc dynamic var synced : Bool = false
    override static func primaryKey() -> String? {
        return "CFormFieldID"
    }
}
