//
//  Utilities.swift
//  XBike
//
//  Created by Eduardo Vasquez on 13/08/22.
//

import Foundation

struct Utilities {

    static func roundDistance(x : Double) -> Int {
        return 10 * Int(round(x / 10.0))
    }
}
