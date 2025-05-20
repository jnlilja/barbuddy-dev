//
//  Bar.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/20/25.
//

import CoreLocation

typealias Bars = [Bar]

struct Bar: Codable, Identifiable, Hashable {
    var id: Int?
    let name: String
    let address: String
    var averagePrice: String?
    let latitude: Double
    let longitude: Double
    var location: String?
    var usersAtBar: Int?
    var currentStatus: String?
    var averageRating: String?
    var images: [BarImage]?
    var currentUserCount: String?
    var activityLevel: String?
    
    // To easier pin location on map, swift's codable protocol ignores computed properties
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var events: [Event] {
        Event.eventData.filter { $0.bar == id }
    }
}

