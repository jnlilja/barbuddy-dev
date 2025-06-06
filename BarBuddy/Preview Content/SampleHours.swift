//
//  SampleHours.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/4/25.
//

import Foundation
extension BarHours {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    static let sampleHours: [BarHours] = [
        BarHours(id: 1, bar: 1, day: "Monday", openTime: dateFormatter.date(from:"10:00:00"), closeTime: dateFormatter.date(from:"2:00:00"), isClosed: false),
        BarHours(id: 1, bar: 2, day: "Tuesday", openTime: dateFormatter.date(from:"16:00:00"), closeTime: dateFormatter.date(from:"1:00:00"), isClosed: false),
        BarHours(id: 1, bar: 3, day: "Saturday", openTime: dateFormatter.date(from:"11:00:00"), closeTime: dateFormatter.date(from:"00:00:00"), isClosed: false),
    ]
}
        
