////
////  SwipeMatching.swift
////  BarBuddy
////
////  Created by Elliot Gambale on 4/16/25.
////
//
import Foundation
import FirebaseAuth

public enum SwipeStatus: String, Codable { case like, dislike }

private struct SwipeRequestBody: Encodable {
    let swiped_on: Int
    let status: String
}

@MainActor
final class MatchingService {
    static let shared = MatchingService()
    private init() {}

    private var swipedIDs = Set<Int>()

    // ───────────────────────── Suggestions
    func suggestions(for me: User) async throws -> [User] {
        // ▼ new: use GetUserAPIService
        let all = try await GetUserAPIService.shared.fetchAll()

        guard let myID = me.id else { return [] }

        let filtered = all.filter { ($0.id ?? -1) != myID && !swipedIDs.contains($0.id ?? -1) }
        let pref = filtered.filter { Self.preferencesMatch($0, me) }
        return pref.sorted { abs($0.ageInYears - me.ageInYears) < abs($1.ageInYears - me.ageInYears) }
    }

    // ───────────────────────── Swipe POST
    func sendSwipe(to userID: Int, status: SwipeStatus) async throws {
        swipedIDs.insert(userID)

        guard let me = Auth.auth().currentUser else { return }
        let token = try await me.getIDToken()

        var req = URLRequest(
            url: URL(string:"https://barbuddy-backend-148659891217.us-central1.run.app/api/swipes")!)
        req.httpMethod = "POST"
        // ▼ new: Bearer header the backend expects
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(
            SwipeRequestBody(swiped_on: userID, status: status.rawValue))

        _ = try await URLSession.shared.data(for: req)
    }

    private static func preferencesMatch(_ a: User, _ b: User) -> Bool {
        let x = (a.sexualPreference ?? "").lowercased()
        let y = (b.sexualPreference ?? "").lowercased()
        return x == "everyone" || x == "both" || y == "everyone" || y == "both" || x == y
    }
}


// MARK: - Age helper
extension User {
    var ageInYears: Int {
        guard
            let dobStr = dateOfBirth,
            let dob = ISO8601DateFormatter().date(from: dobStr + "T00:00:00Z")
        else { return 0 }
        
        return Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 0
    }
}
