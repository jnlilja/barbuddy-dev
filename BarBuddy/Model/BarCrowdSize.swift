//
//  BarCrowdSize.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/30/25.
//

import Foundation

struct BarCrowdSize: Codable {
    let id: Int
    let bar: Int
    let crowdSize: String
    let timestamp: Date
}
