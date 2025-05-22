//
//  BarBuddyTests.swift
//  BarBuddyTests
//
//  Created by Jessica Lilja on 2/5/25.
//  Commit and push test

import Foundation
import Testing

@testable import BarBuddy

@Suite("Hours of Operation")
struct BarBuddyTests {

    // Helper to assert bar open/closed status at a given hour
    private func testIsClosed(openTime: String, closeTime: String, testHour: Int, expectedIsClosed: Bool) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let openDateRaw = formatter.date(from: openTime),
              let closeDateRaw = formatter.date(from: closeTime) else {
            #expect(Bool(false), "Invalid date format")
            return
        }
        let calendar = Calendar.current
        
        var nowComponents = calendar.dateComponents(in: .current, from: Date())
        nowComponents.hour = testHour
        nowComponents.minute = 0
        
        let now = calendar.date(from: nowComponents)!
        var barHourComponents = calendar.dateComponents([.year, .month, .day], from: Date())
       
        barHourComponents.hour = calendar.component(.hour, from: openDateRaw)
        barHourComponents.minute = calendar.component(.minute, from: openDateRaw)
        let openDate = calendar.date(from: barHourComponents)!
        
        barHourComponents.hour = calendar.component(.hour, from: closeDateRaw)
        barHourComponents.minute = calendar.component(.minute, from: closeDateRaw)
        var closeDate = calendar.date(from: barHourComponents)!
        
        if closeDate <= openDate {
            closeDate = calendar.date(byAdding: .day, value: 1, to: closeDate)!
        }
        let isClosed = (now < openDate || now >= closeDate)
        #expect(isClosed == expectedIsClosed, expectedIsClosed ? "Bar is closed" : "Bar is open")
    }

    @Test("Closed after midnight",
          arguments: [
            ("8:00 AM", "1:00 AM"),
            ("1:00 PM", "2:00 AM"),
            ("10:00 PM", "3:00 AM"),
            ("6:00 PM", "12:30 AM"),
            ("11:00 PM", "4:00 AM"),
          ])
    func testIsBarClosed(openTime: String, closeTime: String) throws {
        // Test current time at 5 AM
        testIsClosed(openTime: openTime, closeTime: closeTime, testHour: 5, expectedIsClosed: true)
    }
    
    @Test("Open at 8 AM",
        arguments: [
            ("8:00 AM", "1:00 AM"),
            ("1:00 PM", "2:00 AM"),
            ("10:00 AM", "3:00 AM"),
            ("12:30 PM", "12:30 AM"),
            ("11:00 AM", "4:00 AM")
        ])
    func testIsBarOpen(openTime: String, closeTime: String) throws {
        // Test current time at 1 PM
        testIsClosed(openTime: openTime, closeTime: closeTime, testHour: 13, expectedIsClosed: false)
    }
}
