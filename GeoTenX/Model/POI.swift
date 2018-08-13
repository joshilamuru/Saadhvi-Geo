
//
//  POI.swift
//  sampleForGeo
//
//  Created by saadhvi on 6/22/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class POI: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var address : String = ""
    @objc dynamic var latitude : Double = 0.0
    @objc dynamic var longitude : Double = 0.0
    @objc dynamic var accountID : String = UUID().uuidString
    @objc dynamic var TasktypeID: Int = 0
    @objc dynamic var TypeName: String = ""
    @objc dynamic var createdDate: String = ""
    @objc dynamic var synced : Bool = false
 //   @objc dynamic var done : Bool = false
//    
    override static func primaryKey() -> String? {
        return "accountID"
    }
    func calcDistanceFromUser(userLoc: CLLocation) -> Double {
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: userLoc)
    }
 
    
    
//    init(address: String, latitude: Double, longitude: Double) {
//        self.address = address
//        self.latitude = latitude
//        self.longitude = longitude
       
    }


