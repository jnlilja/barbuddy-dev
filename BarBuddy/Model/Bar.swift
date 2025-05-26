//
//  Bar.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/20/25.
//

import CoreLocation

//struct Bar: Identifiable {
//    let id = UUID()
//    let name: String
//    let location: CLLocationCoordinate2D
//    var musicGenre: String?
//    var usersAtBar: Int?
//    var averageRating: String?
//    var events: [Event] {
//        Event.eventData.filter { $0.location == name }
//    }
//    var deals: [Deal] {
//        Deal.dealData.filter { $0.location == name }
//    }
//}

// Top-level array
typealias Bars = [Bar]

struct Bar: Codable, Identifiable {
    let id: Int
    let name: String
    let address: String
    let average_price: String
    let location: Location
    let images: [BarImage]
    var waitTime: String?
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
}

struct BarImage: Codable {
    let id: Int
    let image: String
    let caption: String
    let uploaded_at: String
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
}

struct CurrentStatus: Codable {
    let crowdSize: Int?
    let waitTime: Int?
    let lastUpdated: Date?

    enum CodingKeys: String, CodingKey {
        case crowdSize = "crowd_size"
        case waitTime = "wait_time"
        case lastUpdated = "last_updated"
    }
}



