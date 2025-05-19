//
//  BarHours.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/12/25.
//

import Foundation

struct BarHours: Codable {
    var id: Int
    var bar: Int
    var day: String?
    var openTime: String?
    var closeTime: String?
    var isClosed: Bool?
    let monday: String?
    let tuesday: String?
    let wednesday: String?
    let thursday: String?
    let friday: String?
    let saturday: String?
    let sunday: String?
}
extension BarHours {
    func toDictionary() -> [String:String] {
        [
            "Monday":    monday    ?? "Closed",
            "Tuesday":   tuesday   ?? "Closed",
            "Wednesday": wednesday ?? "Closed",
            "Thursday":  thursday  ?? "Closed",
            "Friday":    friday    ?? "Closed",
            "Saturday":  saturday  ?? "Closed",
            "Sunday":    sunday    ?? "Closed"
        ]
    }
}
