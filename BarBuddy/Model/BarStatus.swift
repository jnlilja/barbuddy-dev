//
//  BarStatus.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/12/25.
//
import Foundation

struct BarStatus: Codable, Equatable, Sendable {
    var id: Int?
    var bar: Int
    var crowdSize: String?
    var waitTime: String?
    var lastUpdated: String
}
