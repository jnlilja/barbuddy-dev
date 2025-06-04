//
//  MockBarViewModel.swift
//  BarBuddyTests
//
//  Created by Andrew Betancourt on 6/4/25.
//

import Foundation
@testable import BarBuddy

final class MockBarViewModel: Mockable {
    var mockHours: [BarHours] = []
    var currentTime: String = "12:00 PM" // Default time for testing
    
    func getHours(for bar: Bar) async throws -> String? {
        // Mock implementation to return hours as a string
        guard let hours = mockHours.first(where: { $0.bar == bar.id }) else {
            throw BarHoursError.doesNotExist("No hours found for bar with ID \(bar.id)")
        }
        guard
            let openTime = hours.openTime,
            let closeTime = hours.closeTime
        else {
            throw BarHoursError.invalidHourRange
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a" // Format for open/close times
        let open = dateFormatter.string(from: openTime)
        let close = dateFormatter.string(from: closeTime)
        
        let isClosed = isClosed(openTime, closeTime)
        
        return "\(isClosed ? "Closed" : "Open"): \(open) - \(close)"
    }
    
    func isClosed(_ openTime: Date, _ closeTime: Date) -> Bool {
        let calendar = Calendar.current
        
        // Use the default time for testing purposes
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a" // Format for open/close times
        let now = dateFormatter.date(from: currentTime) ?? Date()
        
        // Today's date components
        var openComponents = calendar.dateComponents([.year, .month, .day], from: now)
        var closeComponents = openComponents

        // Extract open and close time parts
        let openHour = calendar.component(.hour, from: openTime)
        let openMinute = calendar.component(.minute, from: openTime)
        let closeHour = calendar.component(.hour, from: closeTime)
        let closeMinute = calendar.component(.minute, from: closeTime)
        
        openComponents.hour = openHour
        openComponents.minute = openMinute
        
        closeComponents.hour = closeHour
        closeComponents.minute = closeMinute

        guard let openDate = calendar.date(from: openComponents),
              var closeDate = calendar.date(from: closeComponents) else {
            return true // Assume closed if dates can't be formed
        }
        
        // If close is earlier than open, assume it spills into next day
        if closeDate <= openDate {
            closeDate = calendar.date(byAdding: .day, value: 1, to: closeDate)!
        }
        
        // Return true if now is outside of the open-close window
        return now < openDate || now >= closeDate
    }

}
