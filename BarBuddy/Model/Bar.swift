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
    var events: [Event] {
        eventData.filter { $0.location == name }
    }
    var deals: [Deal] {
        dealData.filter { $0.location == name }
    }
    var promotions: [Promotion] {
        promotionData.filter { $0.location == name }
    }
}
