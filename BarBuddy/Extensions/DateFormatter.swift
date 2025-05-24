//
//  DateFormatter.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/23/25.
//

import Foundation

extension DateFormatter {
    // This DateFormatter is used to format timestamps for BarBuddy
    static let barBuddyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    // This function formats a Date object into a string using the barBuddyDateFormatter
    static func formatTimeStamp(_ date: Date) -> String {
        return barBuddyDateFormatter.string(from: date)
    }
}


