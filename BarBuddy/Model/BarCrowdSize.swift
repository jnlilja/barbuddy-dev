//
//  BarCrowdSize.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/30/25.
//

import Foundation

struct BarCrowdSize: Codable {
    var id: Int?
    var bar: Int
    var crowdSize: String
    var timestamp: Date?
}
