//
//  Bar.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/20/25.
//

import CoreLocation

typealias Bars = [Bar]

struct Bar: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let address: String
    let averagePrice: String
    let location: Location
    let usersAtBar: [Int]
    let currentStatus: CurrentStatus
    let averageRating: Double?
    let images: [BarImage]
    let currentUserCount: Int
    let activityLevel: String
    
    // To easier pin location on map, swift's codable protocol ignores computed properties when encoding/decoding
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
}
struct Location: Codable, Hashable {
    let latitude: Double
    let longitude: Double
}

struct CurrentStatus: Codable, Hashable {
    let crowdSize: Int?
    let waitTime: Int?
    let lastUpdated: Date?
}
