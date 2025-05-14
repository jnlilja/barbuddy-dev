//
//  Bar.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/20/25.
//

import CoreLocation

// TODO: Update bar model
struct Bar: Codable, Identifiable {
    var id: Int?
    let name: String
    let address: String
    var averagePrice: String
    let latitude: Double
    let longitude: Double
    var location: String
    var usersAtBar: Int
    var currentStatus: String
    var averageRating: String
    var images: [BarImage]
    var currentUserCount: String
    var activityLevel: String
}
