//
//  SwipeMatching.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/16/25.
//
/*
import Foundation
import FirebaseAuth

// MARK: - Swipe API model
enum SwipeStatus: String, Codable { case like, dislike }

struct SwipeEvent: Codable, Identifiable {
    let id: Int
    let swiper_username: String
    let swiped_on: Int
    let swiped_on_username: String
    let status: SwipeStatus
    let timestamp: String
}

enum MatchingError: Error, LocalizedError {
    case noToken, transport(Error), decoding(Error)
    var errorDescription: String? {
        switch self {
        case .noToken:           return "Missing Firebase idToken."
        case .transport(let e):  return e.localizedDescription
        case .decoding(let e):   return "Decoding error: \(e.localizedDescription)"
        }
    }
}

@MainActor
final class MatchingService {
    static let shared = MatchingService()
    private let baseURL = URL(string: "https://YOUR_API_BASE_URL")!
    private init() {}

    // MARK: - Public helpers
    /// Returns users filtered by sexual_preference == current and sorted by age proximity.
    func suggestions(for current: UserProfile) async throws -> [UserProfile] {
        let all = try await UsersFeedService.shared.fetchAll()
        let filtered = all.filter { $0.id != current.id &&
                                    $0.sexual_preference == current.sexual_preference }
        let currentAge = current.ageInYears
        return filtered.sorted { abs($0.ageInYears - currentAge) < abs($1.ageInYears - currentAge) }
    }

    /// POST /swipes  { "swiped_on": id, "status": "like"|"dislike" }
    func sendSwipe(to userID: Int, status: SwipeStatus) async throws {
        guard let me = Auth.auth().currentUser else { throw MatchingError.noToken }
        let token = try await me.getIDToken()
        var req = URLRequest(url: baseURL.appendingPathComponent("swipes"))
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["swiped_on": userID, "status": status.rawValue] as [String : Any]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        do {
            _ = try await URLSession.shared.data(for: req)
        } catch {
            throw MatchingError.transport(error)
        }
    }
}

// MARK: - Age helper
private extension UserProfile {
    var ageInYears: Int {
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"
        guard let dob = formatter.date(from: date_of_birth) else { return 0 }
        return Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 0
    }
}*/
