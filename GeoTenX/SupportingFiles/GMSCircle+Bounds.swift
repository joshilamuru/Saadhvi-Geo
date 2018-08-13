//
//  File.swift
//  sampleForGeo
//
//  Created by saadhvi on 6/21/18.
//  Copyright © 2018 Joshila. All rights reserved.
//
import Foundation
import GoogleMaps

extension GMSCircle {
    func bounds () -> GMSCoordinateBounds {
        func locationMinMax(positive : Bool) -> CLLocationCoordinate2D {
            let sign:Double = positive ? 1 : -1
            let dx = sign * self.radius  / 6378000 * (180/Double.pi)
            let lat = position.latitude + dx
            let lon = position.longitude + dx / cos(position.latitude * Double.pi/180)
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        
        return GMSCoordinateBounds(coordinate: locationMinMax(positive: true),
                                   coordinate: locationMinMax(positive: false))
    }
}
