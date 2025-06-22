//
//  BarHours.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/12/25.
//

import Foundation
typealias Hours = [BarHours]

struct BarHours: Codable, Identifiable, Hashable {
    let id: Int
    let bar: Int
    let day: String
    let openTime: Date?
    let closeTime: Date?
    var isClosed: Bool
    
    var displayHours: String {
        guard let openTime = openTime, let closeTime = closeTime else {
            return "Hours unavailable"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return "\(dateFormatter.string(from: openTime)) - \(dateFormatter.string(from: closeTime))"
    }
}
