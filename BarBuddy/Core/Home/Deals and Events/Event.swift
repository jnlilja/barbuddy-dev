//
//  BarEvent.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/1/25.
//

import Foundation

// MARK: - Models
struct Event: Identifiable, Searchable, Codable {
    let id: Int
    let bar: Int
    let eventName: String
    let eventTime: Date
    let eventDescription: String
    let isToday: String
    let barName: String
    
    func matchesSearch(query: String) -> Bool {
        query.isEmpty || eventName.localizedCaseInsensitiveContains(query)
        || barName.localizedCaseInsensitiveContains(query)
        || eventDescription.localizedCaseInsensitiveContains(query)
    }
    
}
