//
//  BarHours.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/12/25.
//

import Foundation

struct BarHours: Codable {
    var id: Int?
    var bar: Int?
    var day: String
    var openTime: String
    var closeTime: String
    var isClosed: Bool
}
