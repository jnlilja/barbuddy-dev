//
//  SwipeMatching.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/16/25.
//

import Foundation
import FirebaseAuth
import MapKit

public enum SwipeStatus: String, Codable { case like, dislike }

public struct SwipeEvent: Codable, Identifiable {
    public let id: Int
    public let swiper_username: String
    public let swiped_on: Int
    public let swiped_on_username: String
    public let status: SwipeStatus
    public let timestamp: String
}

enum MatchingError: Error, LocalizedError {
    case noToken
    case transport(Error)
    case decoding(Error)
    case outOfZone    // ← re‑added

    var errorDescription: String? {
        switch self {
        case .noToken:           return "Missing Firebase idToken."
        case .transport(let e):  return e.localizedDescription
        case .decoding(let e):   return "Decoding error: \(e.localizedDescription)"
        case .outOfZone:         return "Get Closer to Match with Friends!"
        }
    }
}

@MainActor
final class MatchingService {
    static let shared = MatchingService()
    private let baseURL = URL(string: "https://YOUR_API_BASE_URL")!
    private init() {}

    /// Toggle to ignore bar‑boundary filtering during testing.
    public var ignoreBarFiltering = true

    /// Keeps track of everyone you’ve already swiped on this session.
    private var swipedIDs = Set<Int>()

    /// Returns profiles matching your preference, with same‑bar folks first.
    func suggestions(for current: UserProfile) async throws -> [UserProfile] {
        let all = try await UsersFeedService.shared.fetchAll()

        // 1️⃣ Remove self & anyone already swiped
        let candidates = all.filter {
            $0.id != current.id && !swipedIDs.contains($0.id)
        }

        // 2️⃣ Filter by sexual preference
        let prefMatched = candidates.filter {
            $0.sexual_preference == current.sexual_preference
        }

        // 3️⃣ Parse your coordinate
        guard let meCoord = current.coordinate else {
            // If unable to parse, just sort by age
            return sortByAge(prefMatched, referenceAge: current.ageInYears)
        }

        // 4️⃣ Find which bar‑zone you’re in (unless override)
        let myBar = ignoreBarFiltering
            ? nil
            : BarBoundaries.all.first { $0.contains(meCoord) }

        // 4a️⃣ If not in any bar & override is off, signal “out of zone”
        if myBar == nil && !ignoreBarFiltering {
            throw MatchingError.outOfZone
        }

        // 5️⃣ Split into “same bar” vs “others”
        let (inSameBar, outsideBar) = prefMatched.reduce(into: ([UserProfile](), [UserProfile]())) {
            guard let coord = $1.coordinate,
                  let bar   = myBar,
                  bar.contains(coord)
            else {
                $0.1.append($1)
                return
            }
            $0.0.append($1)
        }

        // 6️⃣ Sort each group by age proximity and concatenate
        let sameSorted   = sortByAge(inSameBar,   referenceAge: current.ageInYears)
        let othersSorted = sortByAge(outsideBar,   referenceAge: current.ageInYears)
        return sameSorted + othersSorted
    }

    /// Helper to POST a swipe and record it locally so it never shows again.
    func sendSwipe(to userID: Int, status: SwipeStatus) async throws {
        // Record immediately
        swipedIDs.insert(userID)

        guard let me = Auth.auth().currentUser else { throw MatchingError.noToken }
        let token = try await me.getIDToken()

        var req = URLRequest(url: baseURL.appendingPathComponent("swipes"))
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["swiped_on": userID, "status": status.rawValue]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        do { _ = try await URLSession.shared.data(for: req) }
        catch { throw MatchingError.transport(error) }
    }

    // MARK: – Private helpers

    private func sortByAge(_ list: [UserProfile], referenceAge: Int) -> [UserProfile] {
        list.sorted { abs($0.ageInYears - referenceAge) < abs($1.ageInYears - referenceAge) }
    }
}

// MARK: – Convenience extensions on UserProfile

extension UserProfile {
    /// Parses `location` as “lat,lon” → coordinate, if possible.
    var coordinate: CLLocationCoordinate2D? {
        let parts = location
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count == 2,
              let lat = Double(parts[0]),
              let lon = Double(parts[1])
        else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    /// Your age in years, used for proximity sorting.
    var ageInYears: Int {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        guard let dob = fmt.date(from: date_of_birth) else { return 0 }
        return Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 0
    }
}

