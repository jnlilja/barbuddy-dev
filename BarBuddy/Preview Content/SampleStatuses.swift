//
//  SampleStatuses.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/4/25.
//

import Foundation

extension BarStatus {
    static let sampleStatuses: [BarStatus] = [
        BarStatus(id: 1, bar: 1, crowdSize: "moderate", waitTime: "<5 min", lastUpdated: Date()),
        BarStatus(id: 2, bar: 2, crowdSize: "busy", waitTime: "10-15 min", lastUpdated: Date()),
        BarStatus(id: 3, bar: 3, crowdSize: "moderate", waitTime: "15-20 min", lastUpdated: Date()),
        BarStatus(id: 4, bar: 4, crowdSize: "moderate", waitTime: "15-20 min", lastUpdated: Date()),
    ]
}
