//
//  Bar.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/20/25.
//
import CoreLocation

struct Bar: Codable, Identifiable, Hashable, CustomStringConvertible {
    let id: Int
    let name: String
    let address: String
    let averagePrice: String
    let location: Location
    let usersAtBar: [Int]
    let currentStatus: CurrentStatus
    let averageRating: Int?
    let images: [BarImage]
    let currentUserCount: Int
    let activityLevel: String
    
    // To easier pin location on map, swift's codable protocol ignores this computed property when encoding/decoding
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
    
    // Nice to have a string representation of the bar for debugging purposes.
    var description: String {
        """
        - Bar Info -
        name: \(name)
        id: \(id)
        address: \(address)
        coordinate: \(coordinate)
        -----
        """
    }
}
