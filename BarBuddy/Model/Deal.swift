//
//  Deal.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/25/25.
//

import Foundation

struct Deal: Identifiable, DayFilterable, Searchable {
    let id = UUID()
    let title: String
    let location: String
    let description: String
    let days: [DealsAndEventsView.DayFilter]
    
    var daysString: String {
        if days.count == 7 {
            return "Daily"
        } else if days.count == 1 {
            return days[0].rawValue + "s"
        } else {
            return days.map { $0.rawValue }.joined(separator: ", ")
        }
    }
    
    func matchesSearch(query: String) -> Bool {
        return title.lowercased().contains(query.lowercased()) ||
               location.lowercased().contains(query.lowercased()) ||
               description.lowercased().contains(query.lowercased())
    }
}
