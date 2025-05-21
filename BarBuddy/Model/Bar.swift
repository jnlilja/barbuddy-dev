//
//  Bar.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/20/25.
//

import CoreLocation

typealias Bars = [Bar]

struct Bar: Codable, Identifiable, Hashable {
    var id: Int?
    let name: String
    let address: String
    var averagePrice: String?
    let latitude: Double
    let longitude: Double
    var location: String?
    var usersAtBar: Int?
    var currentStatus: String?
    var averageRating: String?
    var images: [BarImage]?
    var currentUserCount: String?
    var activityLevel: String?
    
    // To easier pin location on map, swift's codable protocol ignores computed properties when encoding/decoding
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var events: [Event] {
        Event.eventData.filter { $0.bar == id }
    }
    
    // Function to fetch the bar's hours
    func getHours() async -> String? {
        guard let id = id else { return nil }
        // Try to get from cache
        if var cached = await BarHoursCache.shared.get(for: id) {
            guard let open = cached.openTime,
                    let close = cached.closeTime else { return nil }
            
            let closed = isClosed(open, close)
            cached.isClosed = closed
            // Patch hours and update cache
            do {
                try await BarNetworkManager.shared.patchBarHours(id: cached.id)
                await BarHoursCache.shared.set(cached, for: cached.id)
            } catch {
                print("Could not patch hours")
            }
            return "\(closed ? "Closed" : "Open"): \(open) - \(close)"
        }
        // Fetch all hours if not in cache
        do {
            let allHours = try await BarNetworkManager.shared.fetchAllBarHours()
            guard var hours = allHours.first(where: { $0.bar == id }) else { return nil }
            // Cache all fetched hours
            for h in allHours {
                await BarHoursCache.shared.set(h, for: h.id)
            }
            guard let open = hours.openTime,
                    let close = hours.closeTime else { return nil }
            let closed = isClosed(open, close)
            hours.isClosed = closed
            // Patch hours and update cache
            do {
                try await BarNetworkManager.shared.patchBarHours(id: hours.id)
                await BarHoursCache.shared.set(hours, for: hours.id)
            } catch {
                print("Could not patch hours")
            }
            return "\(closed ? "Closed" : "Open"): \(open) - \(close)"
        } catch {
            print("Could not fetch hours")
        }
        return nil
    }
    
    // Check if the bar is closed based on the current time and the bar's hours
    private func isClosed(_ openTime: String, _ closeTime: String) -> Bool {
        // Only handle 12-hour format with AM/PM
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard
            let openDateRaw = formatter.date(from: openTime),
            let closeDateRaw = formatter.date(from: closeTime)
        else {
            return true
        }

        let calendar = Calendar.current

        // Get the current date and time
        let nowComponents = calendar.dateComponents(in: .current, from: Date())
        let now = calendar.date(from: nowComponents)!

        // Get today's open and close times
        var barHourComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        
        barHourComponents.hour = calendar.component(.hour, from: openDateRaw)
        barHourComponents.minute = calendar.component(.minute, from: openDateRaw)
        let openDate = calendar.date(from: barHourComponents)!

        barHourComponents.hour = calendar.component(.hour, from: closeDateRaw)
        barHourComponents.minute = calendar.component(.minute, from: closeDateRaw)
        var closeDate = calendar.date(from: barHourComponents)!

        // If close time is earlier than open, it means it goes into the next day
        if closeDate <= openDate {
            closeDate = calendar.date(byAdding: .day, value: 1, to: closeDate)!
        }
        
        // Check if the current time is outside the open hours
        return now < openDate || now >= closeDate
    }
}
