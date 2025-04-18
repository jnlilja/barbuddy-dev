//
//  BarStatusService.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/18/25.
//  Updated — make models Sendable
//

import Foundation
import FirebaseAuth

// MARK: – Models matching your DRF serializers
public struct BarStatus: Codable, Equatable, Sendable {
    public let id: Int
    public let bar: Int
    public let crowd_size: String
    public let wait_time: String
    public let last_updated: String
}

public struct VoteSummary: Codable, Equatable, Sendable {
    public let id: Int
    public let bar: Int
    public let crowd_size: String
    public let wait_time: String
    public let timestamp: String
}

public actor BarStatusService {
    public static let shared = BarStatusService()
    private let baseURL = URL(string: "https://your‑api‑url.com")!
    private init() {}

    // GET /bar-status/
    public func fetchStatuses() async throws -> [BarStatus] {
        let url = baseURL.appendingPathComponent("bar-status/")
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([BarStatus].self, from: data)
    }

    // GET /bar-votes/summary/
    public func fetchVoteSummaries() async throws -> [VoteSummary] {
        let url = baseURL.appendingPathComponent("bar-votes/summary/")
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([VoteSummary].self, from: data)
    }

    // POST /bar-votes/
    public func submitVote(barId: Int, crowdSize: String, waitTime: String) async throws {
        let url = baseURL.appendingPathComponent("bar-votes/")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["bar": barId,
                    "crowd_size": crowdSize,
                    "wait_time": waitTime] as [String: Any]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (_, resp) = try await URLSession.shared.data(for: req)
        guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
    }
}
