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

public struct BarMusic: Codable, Equatable, Sendable {
    public let id: Int
    public let bar: Int
    public let music: String
}

public struct BarPricing: Codable, Equatable, Sendable {
    public let id: Int
    public let bar: Int
    public let price_range: String
}

public actor BarStatusService {
    public static let shared = BarStatusService()
    private let baseURL = URL(string: "barbuddy-backend-148659891217.us-central1.run.app/api")!
    private init() {}
    
    //GET bars
    func fetchBars() async -> Bars? {
        let url = URL(string: "https://barbuddy-backend-148659891217.us-central1.run.app/api/bars/")!
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        do {
            let idToken = try await currentUser.getIDToken()
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("bar json")
                print(jsonString)
            } else {
                print("no json data for bars")
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let bars = try decoder.decode(Bars.self, from: data)
            return bars
        } catch {
            print("error getting bars")
            return nil
        }
    }

    // GET /bar-status/
    public func fetchStatuses() async throws -> [BarStatus] {
        let url = baseURL.appendingPathComponent("bar-status/")
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([BarStatus].self, from: data)
    }

    // GET /bar-votes/summary/
    public func fetchVoteSummaries() async throws -> [VoteSummary] {
        let url = baseURL.appendingPathComponent("bar-votes/summary/")
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([VoteSummary].self, from: data)
    }

    // GET /bar-music/
    public func fetchMusic() async throws -> [BarMusic] {
        let url = baseURL.appendingPathComponent("bar-music/")
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([BarMusic].self, from: data)
    }

    // GET /bar-pricing/
    public func fetchPricing() async throws -> [BarPricing] {
        let url = baseURL.appendingPathComponent("bar-pricing/")
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([BarPricing].self, from: data)
    }

    // POST /bar-votes/
    public func submitVote(barId: Int, crowdSize: String, waitTime: String) async throws {
        let url = baseURL.appendingPathComponent("bar-votes/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "bar": barId,
            "crowd_size": crowdSize,
            "wait_time": waitTime
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (_, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
    }
}
