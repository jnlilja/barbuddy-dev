//
//  Location.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/23/25.
//

import Foundation

struct Location: Codable, Hashable, CustomStringConvertible {
    var latitude: Double
    var longitude: Double
    
    public var description: String {
        "Location (latitude: \(latitude), longitude: \(longitude))"
    }
}
