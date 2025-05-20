//
//  BarHours.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/12/25.
//

import Foundation

struct BarHours: Codable, Identifiable, Hashable {
    enum Day: String, Codable, CaseIterable {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }

    var id: Int
    let bar: Int
    let day: Day
    let openTime: String?
    let closeTime: String?
    let isClosed: Bool

    private enum CodingKeys: String, CodingKey {
        case id, bar, day
        case openTime  = "open_time"
        case closeTime = "close_time"
        case isClosed  = "is_closed"
    }

    
    var displayHours: String {
        guard !isClosed else { return "Closed" }
        guard let openTime, let closeTime else { return "Hours unavailable" }
        return Self.pretty(openTime) + " – " + Self.pretty(closeTime)
    }

    
    private static func pretty(_ backendTime: String) -> String {
        let inFmt  = DateFormatter(); inFmt.dateFormat = "HH:mm:ss"
        let outFmt = DateFormatter(); outFmt.dateFormat = "h:mm a"; outFmt.amSymbol = "AM"; outFmt.pmSymbol = "PM"
        if let date = inFmt.date(from: backendTime) {
            return outFmt.string(from: date)
        }
        return backendTime
    }
}


private extension Calendar {
    /// Sunday = 6, Monday = 0, … – matches `Day` order
    var weekdayIndexZeroBased: Int {
        (component(.weekday, from: Date()) + 5) % 7
    }
}

