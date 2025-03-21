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
    var events: [Event] = []
}
