
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
    @objc dynamic var accountID : Int = 0
    @objc dynamic var accountIDfrmMobile: String = UUID().uuidString
    @objc dynamic var AccountTypeID: Int = 0
    @objc dynamic var createdDate: String = ""
    @objc dynamic var synced : Bool = false
    @objc dynamic var AccountDescription : String = ""
    @objc dynamic var status : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var fromServer: Bool = false
    @objc dynamic var accountIDToServer: Int = 0
    
    override static func primaryKey() -> String? {
        return "accountIDfrmMobile"
    }
    func calcDistanceFromUser(userLoc: CLLocation) -> Double {
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: userLoc)
    }
 
    func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(POI.self).max(ofProperty: "accountIDToServer") as Int? ?? 0) + 1
    }
    func distanceFromUser(userLoc: CLLocation) -> Double {
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: userLoc)
    }
    
//    init(address: String, latitude: Double, longitude: Double) {
//        self.address = address
//        self.latitude = latitude
//        self.longitude = longitude
       
    }


