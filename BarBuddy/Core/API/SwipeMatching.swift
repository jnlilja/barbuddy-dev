//
//  SwipeMatching.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/16/25.
//
import Foundation
import FirebaseAuth

// MARK: ‑ Dependent models
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
    case outOfZone          // ← NEW

    var errorDescription: String? {
        switch self {
        case .noToken:           return "Missing Firebase idToken."
        case .transport(let e):  return e.localizedDescription
        case .decoding(let e):   return "Decoding error: \(e.localizedDescription)"
        case .outOfZone:         return nil              // handled by caller
        }
    }
}

// MARK: ‑ Service
@MainActor
final class MatchingService {
    static let shared = MatchingService()
    private let baseURL = URL(string: "https://YOUR_API_BASE_URL")!
    private init() {}

    /// Set to **true** during development to ignore Pacific Beach filtering.
    var locationOverrideForTesting = false

    // MARK: ‑ Public API
    /// Returns users in Pacific Beach with matching sexual preference, ordered by age proximity.
    func suggestions(for current: UserProfile) async throws -> [UserProfile] {
        let all = try await UsersFeedService.shared.fetchAll()

        // 1. Remove myself
        let others = all.filter { $0.id != current.id }

        // 2. Match sexual preference
        let prefMatched = others.filter { $0.sexual_preference == current.sexual_preference }

        /// 3. Location filter – Pacific Beach unless override
        let locationMatched = locationOverrideForTesting
            ? prefMatched
            : prefMatched.filter { $0.location.localizedCaseInsensitiveContains("pacific beach") }

        guard !locationMatched.isEmpty else { throw MatchingError.outOfZone }

        // 4. Sort by age proximity
        let meAge = current.ageInYears
        return locationMatched.sorted { abs($0.ageInYears - meAge) < abs($1.ageInYears - meAge) }
    }

    /// POSTs a swipe event for the current user.
    func sendSwipe(to userID: Int, status: SwipeStatus) async throws {
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
}

// MARK: ‑ Convenience age + location helpers on model
extension UserProfile {
    var ageInYears: Int {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        guard let dob = fmt.date(from: date_of_birth) else { return 0 }
        return Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 0
    }
}
