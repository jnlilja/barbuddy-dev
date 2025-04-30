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

public struct SwipeEvent: Codable, Identifiable {
    public let id: Int
    public let swiper_username: String
    public let swiped_on: Int
    public let swiped_on_username: String
    public let status: SwipeStatus
    public let timestamp: String
}

private struct SwipeRequestBody: Encodable {
    let swiped_on: Int
    let status: String
}

enum MatchingError: Error, LocalizedError {
    case noToken, transport(Error), decoding(Error),
         invalidAuthUser, noSelfProfile

    var errorDescription: String? {
        switch self {
        case .noToken:          return "Missing Firebase idToken."
        case .transport(let e): return e.localizedDescription
        case .decoding(let e):  return "Decoding error: \(e.localizedDescription)"
        case .invalidAuthUser:  return "Could not determine the signed-in user."
        case .noSelfProfile:    return "Could not find your own profile."
        }
    }
}

@MainActor
final class MatchingService {
    static let shared = MatchingService()
    private init() {}

    // local cache of IDs you’ve already swiped this launch
    private var swipedIDs = Set<Int>()

    // ───────────────────────────────────────── Suggestions
    func suggestions(for me: User) async throws -> [User] {
        let all = try await UserAPIService.shared.fetchAll()

        guard let myID = me.id else { throw MatchingError.noSelfProfile }

        // remove yourself & already-swiped
        let filtered = all.filter { user in
            guard let uid = user.id else { return false }
            return uid != myID && !swipedIDs.contains(uid)
        }

        // mutual sexual-preference
        let prefMatched = filtered.filter { Self.preferencesMatch($0, me) }

        // sort by absolute age-difference
        return prefMatched.sorted {
            abs($0.ageInYears - me.ageInYears) < abs($1.ageInYears - me.ageInYears)
        }
    }

    // ───────────────────────────────────────── Swipe POST
    func sendSwipe(to userID: Int, status: SwipeStatus) async throws {
        swipedIDs.insert(userID)    // optimistic

        guard let me = Auth.auth().currentUser else { throw MatchingError.noToken }
        let token = try await me.getIDToken()

        var req = URLRequest(
            url: URL(string:
              "https://barbuddy-backend-148659891217.us-central1.run.app/api/swipes")!)
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = SwipeRequestBody(swiped_on: userID, status: status.rawValue)
        req.httpBody = try JSONEncoder().encode(body)

        do { _ = try await URLSession.shared.data(for: req) }
        catch { throw MatchingError.transport(error) }
    }

    // ───────────────────────────────────────── Helpers
    private static func preferencesMatch(_ a: User, _ b: User) -> Bool {
        let x = (a.sexualPreference ?? "").lowercased()
        let y = (b.sexualPreference ?? "").lowercased()

        if x == "both" || x == "everyone" { return true }
        if y == "both" || y == "everyone" { return true }
        return x == y
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
