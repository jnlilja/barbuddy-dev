//
//  Bar.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/20/25.
//

import CoreLocation

struct Bar: Identifiable {
    let id = UUID()
    let name: String
    let location: CLLocationCoordinate2D
    var musicGenre: String?
    var usersAtBar: Int?
    var averageRating: String?
    var events: [Event] {
        Event.eventData.filter { $0.location == name }
    }
    var deals: [Deal] {
        Deal.dealData.filter { $0.location == name }
    }
}
