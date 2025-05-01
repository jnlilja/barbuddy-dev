//
//  BarStatusService.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/18/25.
//  Updated — make models Sendable
//

import Foundation
import FirebaseAuth

// ─────────── Models ───────────

public struct BarStatus: Codable, Equatable, Sendable {
    public let id: Int
    public let bar: Int
    public let crowdSize: String      // ← JSON crowd_size
    public let waitTime:  String      // ← JSON wait_time
    public let lastUpdated: String

    // 🩹 legacy snake-case aliases so old code still compiles
    public var crowd_size: String { crowdSize }
    public var wait_time:  String { waitTime  }
}

public struct VoteSummary: Codable, Equatable, Sendable {
    public let id: Int
    public let bar: Int
    public let crowdSize: String
    public let waitTime:  String
    public let timestamp: String
}

public struct BarMusic: Codable, Equatable, Sendable {
    public let id: Int
    public let bar: Int
    public let music: String
}

public struct BarPricing: Codable, Equatable, Sendable {
    public let id: Int
    public let bar: Int
    public let priceRange: String     // ← JSON price_range

    // 🩹 legacy alias
    public var price_range: String { priceRange }
}

// ─────────── Service ───────────

public actor BarStatusService {
    public static let shared = BarStatusService(); private init() {}

    private let baseURL = URL(
        string: "https://barbuddy-backend-148659891217.us-central1.run.app/api")!

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase   // snake_case → camelCase
        return d
    }()

    // MARK: – generic GET helper
    private func get<T: Decodable>(_ path: String) async throws -> T {
        guard let fb = Auth.auth().currentUser else { throw URLError(.userAuthenticationRequired) }
        let token = try await fb.getIDToken()

        var req = URLRequest(url: baseURL.appendingPathComponent(path))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        
        let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
        if code != 200 {
            print("🛑 \(path) responded", code,
                  String(data: data, encoding: .utf8) ?? "no body")
            throw URLError(.badServerResponse)
        }

        
        return try decoder.decode(T.self, from: data)
        
    }

    // MARK: – Endpoints
    public func fetchStatuses()      async throws -> [BarStatus]   { try await get("bar-status/") }
    public func fetchVoteSummaries() async throws -> [VoteSummary] { try await get("bar-votes/summary/") }
    public func fetchMusic()         async throws -> [BarMusic]    { try await get("bar-music/") }
    public func fetchPricing()       async throws -> [BarPricing]  { try await get("bar-pricing/") }

    // MARK: – POST vote
    public func submitVote(barId: Int, crowdSize: String, waitTime: String) async throws {
        guard let fb = Auth.auth().currentUser else { throw URLError(.userAuthenticationRequired) }
        let token = try await fb.getIDToken()

        var req = URLRequest(url: baseURL.appendingPathComponent("bar-votes/"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)",    forHTTPHeaderField: "Authorization")

        let body = ["bar": barId,
                    "crowd_size": crowdSize,
                    "wait_time":  waitTime] as [String : Any]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, resp) = try await URLSession.shared.data(for: req)
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else { throw URLError(.badServerResponse) }
    }
}
