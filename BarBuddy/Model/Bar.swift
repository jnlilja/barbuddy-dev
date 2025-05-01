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

struct BarImage: Codable {
    var id: Int
    var image: String
    var caption: String
    var uploadedAt: String
}

struct BarVote: Codable {
    var id: Int
    var bar: String
    var crowdSize: String
    var waitTime: String
    var timeStamp: String
}
// Commented out since the old struct is still in use
//struct BarStatus: Codable {
//    var id: Int
//    var bar: Int
//    var crowdSize: String
//    var waitTime: String
//    var lastUpdated: String
//}

struct BarHours: Codable {
    var id: Int
    var bar: Int
    var openTime: String
    var closeTime: String
    var isClosed: Bool
}
