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
    var waitTime: String
    let lastUpdated: Date
}
    