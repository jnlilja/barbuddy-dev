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
    
    // Needs to be on the main actor because it is a cached value that is accessed from multiple threads
    // This is a temporary solution until we can find a better way to cache data
    @MainActor private static var cacheHours: [Int: BarHours] = [:]
    
    // To easier pin location on map, swift's codable protocol ignores computed properties when encoding/decoding
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var events: [Event] {
        Event.eventData.filter { $0.bar == id }
    }
    
    // Function to fetch the bar's hours
    func getHours() async -> String? {
        if let id = id, let cached = await Bar.cacheHours[id] {
            let (open, close) = (cached.openTime, cached.closeTime)
            let closed = isClosed(open, close)
            return "\(closed ? "Closed" : "Open"): \(open ?? "N/A") - \(close ?? "N/A")"
        }
        async let allHours = BarNetworkManager.shared.fetchAllBarHours()
        do {
            if let hours = try await allHours.first(where: { $0.bar == id }) {
                // Cache the hours
                await MainActor.run { Bar.cacheHours[hours.id] = hours }
                let (open, close) = (hours.openTime, hours.closeTime)
                let closed = isClosed(open, close)
                return "\(closed ? "Closed" : "Open"): \(open ?? "N/A") - \(close ?? "N/A")"
            }
        } catch {
            print("Could not fetch hours")
        }
        return nil
    }
    
    // Check if the bar is closed based on the current time and the bar's hours
    private func isClosed(_ openTime: String?, _ closeTime: String?) -> Bool {
        guard let open = openTime, let close = closeTime else { return true }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let openDate = formatter.date(from: open),
              let closeDate = formatter.date(from: close) else { return true }
        let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
        guard let nowDate = formatter.date(from: String(format: "%02d:%02d", now.hour ?? 0, now.minute ?? 0)) else { return true }
        return nowDate < openDate || nowDate > closeDate
    }
}
