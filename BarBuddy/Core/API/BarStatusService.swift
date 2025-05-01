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
    public let crowdSize: String          // crowd_size in JSON
    public let waitTime:  String          // wait_time  in JSON
    public let lastUpdated: String?       // last_updated

    // legacy alias
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

public struct BarHours: Codable, Equatable, Sendable {
    public let id: Int
    public let bar: Int
    public let day: String               // "MON", "TUE", … (backend enum of 7)
    public let openTime:  String?        // open_time  (nullable)
    public let closeTime: String?        // close_time (nullable)
    public let isClosed:  Bool           // is_closed

    // snake-case shims for legacy code
    public var open_time:  String? { openTime  }
    public var close_time: String? { closeTime }
    public var is_closed:  Bool     { isClosed  }
}

public struct BarMusic:   Codable, Equatable, Sendable { public let id, bar: Int; public let music: String }
public struct BarPricing: Codable, Equatable, Sendable {
    public let id, bar: Int
    public let priceRange: String        // price_range
    public var price_range: String { priceRange }
}

// ─────────── Service ───────────

public actor BarStatusService {
    public static let shared = BarStatusService(); private init() {}

    private let baseURL = URL(
        string: "https://barbuddy-backend-148659891217.us-central1.run.app/api")!

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    // MARK: – generic GET
    private func get<T: Decodable>(_ path: String) async throws -> T {
        let fbUser = try await AuthAwaiter.waitForUser()
        let token  = try await fbUser.getIDToken()
        var req = URLRequest(url: baseURL.appendingPathComponent(path))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, resp) = try await URLSession.shared.data(for: req)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
        guard code == 200 else {
            print("🛑 \(path) responded \(code)",
                  String(data: data, encoding: .utf8) ?? "no body")
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(T.self, from: data)
    }

    // MARK: – Endpoints
    public func fetchStatuses()      async throws -> [BarStatus]  { try await get("bar-status/") }
    public func fetchVoteSummaries() async throws -> [VoteSummary]{ try await get("bar-votes/summary/") }
    public func fetchMusic()         async throws -> [BarMusic]   { try await get("bar-music/") }
    public func fetchPricing()       async throws -> [BarPricing] { try await get("bar-pricing/") }

    /// GET /bar-hours/by_bar/?bar=<id>  – hours for a single bar
    public func fetchHours(for barId: Int) async throws -> [BarHours] {
        try await get("bar-hours/by_bar/?bar=\(barId)")
    }

    // MARK: – POST vote
    public func submitVote(barId: Int, crowdSize: String, waitTime: String) async throws {
        let fbUser = try await AuthAwaiter.waitForUser()
        let token  = try await fbUser.getIDToken()

        var req = URLRequest(url: baseURL.appendingPathComponent("bar-votes/"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)",  forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "bar":        barId,
            "crowd_size": crowdSize,
            "wait_time":  waitTime
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, resp) = try await URLSession.shared.data(for: req)
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
    }
}
