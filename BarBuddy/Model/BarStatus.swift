//
//  BarStatus.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/12/25.
//
import Foundation

struct BarStatus: Codable, Equatable, Sendable {
    let id: Int
    let bar: Int
    let crowdSize: String
    var waitTime: String
    let lastUpdated: Date
    
    var formattedWaitTime: String {
        waitTime
            .replacingOccurrences(of: "<", with: "< ")
            .replacingOccurrences(of: ">", with: "> ")
            .replacingOccurrences(of: "-", with: " - ")
    }
}
    
