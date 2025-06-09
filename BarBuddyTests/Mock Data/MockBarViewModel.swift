//
//  MockBarViewModel.swift
//  BarBuddyTests
//
//  Created by Andrew Betancourt on 6/4/25.
//
#if DEBUG
import Foundation

@Observable
final class MockBarViewModel: Mockable {
    var mockHours: [BarHours]
    var mockBars: [Bar]
    var mockStatuses: [BarStatus]
    var currentTime: String
    var networkManager: NetworkTestable
    
    init(currentTime: String = "12:00 PM") {
        self.currentTime = currentTime
        self.mockHours = []
        self.mockBars = []
        self.mockStatuses = []
        self.networkManager = MockBarNetworkManager()
    }
    
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let now = dateFormatter.date(from: currentTime) ?? Date()
        
        let openComponents = calendar.dateComponents([.hour, .minute], from: openTime)
        let closeComponents = calendar.dateComponents([.hour, .minute], from: closeTime)
        
        var todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        
        todayComponents.hour = openComponents.hour
        todayComponents.minute = openComponents.minute
        guard let openDate = calendar.date(from: todayComponents) else {
            return true
        }
        
        todayComponents.hour = closeComponents.hour
        todayComponents.minute = closeComponents.minute
        guard var closeDate = calendar.date(from: todayComponents) else {
            return true
        }
        
        if closeDate <= openDate {
            closeDate = calendar.date(byAdding: .day, value: 1, to: closeDate)!
        }
        
        if now < openDate {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
            var yesterdayComponents = calendar.dateComponents([.year, .month, .day], from: yesterday)
            
            yesterdayComponents.hour = openComponents.hour
            yesterdayComponents.minute = openComponents.minute
            guard let previousOpenDate = calendar.date(from: yesterdayComponents) else {
                return true
            }
            
            yesterdayComponents.hour = closeComponents.hour
            yesterdayComponents.minute = closeComponents.minute
            guard var previousCloseDate = calendar.date(from: yesterdayComponents) else {
                return true
            }
            
            if previousCloseDate <= previousOpenDate {
                previousCloseDate = calendar.date(byAdding: .day, value: 1, to: previousCloseDate)!
            }
            
            return now < previousOpenDate || now >= previousCloseDate
        }
        
        return now < openDate || now >= closeDate
    }

}
#endif
