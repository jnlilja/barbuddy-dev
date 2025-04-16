//
//  Deal.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/25/25.
//

import Foundation

struct Deal: Identifiable{
    
    let id = UUID()
    let title: String
    let location: String
    let timeDescription: String
    let description: String
    let day: [String]
    
//    var daysString: String {
//        if description.count == 7 {
//            return "Daily"
//        } else if description.count == 1 {
//            return description[0].rawValue + "s"
//        } else {
//            return description.map { $0.rawValue }.joined(separator: ", ")
//        }
//    }
    
    func matchesSearch(query: String) -> Bool {
        return title.lowercased().contains(query.lowercased()) ||
               location.lowercased().contains(query.lowercased()) ||
               description.lowercased().contains(query.lowercased())
    }
}
