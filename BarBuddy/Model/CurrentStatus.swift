//
//  CurrentStatus.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/18/25.
//
import Foundation

struct CurrentStatus: Codable, Hashable {
    let crowdSize: String?
    let waitTime: String?
    let lastUpdated: Date?
}
