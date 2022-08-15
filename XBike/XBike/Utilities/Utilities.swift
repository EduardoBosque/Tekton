//
//  Utilities.swift
//  XBike
//
//  Created by Eduardo Vasquez on 13/08/22.
//

import Foundation
import GoogleMaps

struct Utilities {

    static func roundDistance(x : Double) -> Int {
        return 10 * Int(round(x / 10.0))
    }
    
    static func distanceBetween(startPosition: CLLocationCoordinate2D, destinationPosition: CLLocationCoordinate2D) -> Int {
        let userLocation = CLLocation(latitude: startPosition.latitude, longitude: startPosition.longitude)
        let destinationLocation = CLLocation(latitude: destinationPosition.latitude, longitude: destinationPosition.longitude)
        let distance = userLocation.distance(from: destinationLocation)
        
        return roundDistance(x: distance)
    }
}
