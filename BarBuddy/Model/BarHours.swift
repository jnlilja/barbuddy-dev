//
//  BarHours.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/12/25.
//

import Foundation

struct BarHours: Codable, Identifiable, Hashable {
    let id: Int
    let bar: Int
    let day: String
    let openTime: String
    let closeTime: String
    var isClosed: Bool
}
