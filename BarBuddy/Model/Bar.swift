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
            
            // Get last cached status and check if it needs to be updated
            let previousClosedStatus = cached.isClosed
            let isCurrentlyClosed = isClosed(open, close)
            
            // If the status has not changed, do not update
            guard previousClosedStatus != isCurrentlyClosed else {
                return "\(isCurrentlyClosed ? "Closed" : "Open"): \(open) - \(close)"
            }
            cached.isClosed = isCurrentlyClosed
            
            // Patch hours and update cache
            do {
                try await BarNetworkManager.shared.patchBarHours(id: cached.id)
                await BarHoursCache.shared.set(value: cached, forKey: cached.id)
            } catch {
                switch error {
                case BarHoursError.doesNotExist(error: let error):
                    print("patchHours error: \(error)")
                case APIError.noToken:
                    print("patchHours error: No token. Please log in.")
                case APIError.badRequest:
                    print("patchHours error: Bad request")
                case APIError.badURL:
                    print("patchHours error: URL is not valid.")
                default:
                    print("Pathing hours failed with error - \(error.localizedDescription)")
                }
                return nil
            }
            return "\(isCurrentlyClosed ? "Closed" : "Open"): \(open) - \(close)"
        }
        // Fetch all hours if not in cache
        do {
            let allHours = try await BarNetworkManager.shared.fetchAllBarHours()
            guard var hours = allHours.first(where: { $0.bar == id }) else { return nil }
            
            // Cache all fetched hours
            for h in allHours {
                await BarHoursCache.shared.set(value: h, forKey: h.id)
            }
            
            guard let open = hours.openTime,
                    let close = hours.closeTime else { return nil }
            let closed = isClosed(open, close)
            hours.isClosed = closed
            
            // Patch hours and update cache
            do {
                try await BarNetworkManager.shared.patchBarHours(id: hours.id)
                await BarHoursCache.shared.set(value: hours, forKey: hours.id)
            } catch {
                switch error {
                case BarHoursError.doesNotExist(error: let error):
                    print("patchHours error: \(error)")
                case APIError.noToken:
                    print("patchHours error: No token. Please log in.")
                case APIError.badRequest:
                    print("patchHours error: Bad request")
                case APIError.badURL:
                    print("patchHours error: URL is not valid.")
                default:
                    print("Pathing hours failed with error - \(error.localizedDescription)")
                }
                return nil
            }
            return "\(closed ? "Closed" : "Open"): \(open) - \(close)"
            
        } catch APIError.badRequest {
            print("Could not fetch hours")
        } catch APIError.noToken {
            print("Could not fetch hours. No token.")
        } catch APIError.badURL {
            print("Could not fetch hours. URL is not valid.")
        } catch {
            print("Could not fetch hours - \(error.localizedDescription)")
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

extension Bar {
    // For testing purposes
    static let DUMMY_DATA = Bar(
        id: 1,
        name: "Example Bar",
        address: "123 Main St, Anytown, USA",
        averagePrice: nil,
        latitude: 37.7749,
        longitude: -122.4194,
        location: nil,
        usersAtBar: nil,
        currentStatus: nil,
        averageRating: nil,
        images: nil,
        currentUserCount: nil,
        activityLevel: nil
    )
}
