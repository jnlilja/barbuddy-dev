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
    var bar: Int
    var day: String?
    var openTime: String?
    var closeTime: String?
    var isClosed: Bool?
}
