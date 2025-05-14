//
//  BarStatusService.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/18/25.
//  Updated — make models Sendable
//

import Foundation
@preconcurrency import FirebaseAuth

// MARK: – Models matching your DRF serializers
actor BarStatusService {
    static let shared = BarStatusService()
    private let session: URLSession
    private let baseURL = ProcessInfo.processInfo.environment["BASE_URL"] ?? ""
    private let (encoder, decoder) = (JSONEncoder(), JSONDecoder())
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
   
    // GET /bar-status/
    func fetchStatuses() async throws -> [BarStatus] {
        let endpoint = baseURL + "bar-status/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
        }
        guard let token = try await SessionManager().authUser?.getIDToken() else {
            throw APIError.noToken
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(from: url)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            print("Error fetching statuses: \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([BarStatus].self, from: data)
    }
    
    // GET /bar-votes/summary/
    func fetchVoteSummaries() async throws -> [BarVote] {
        let endpoint = baseURL + "bar-votes/summary/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
        }
        guard let token = try await SessionManager().authUser?.getIDToken() else {
            throw APIError.noToken
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([BarVote].self, from: data)
    }
    
    // POST /bar-votes/
    func submitVote(vote: BarVote) async throws {
        let endpoint = baseURL + "bar-votes/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
        }
        guard let token = try await SessionManager().authUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(vote)
        let (_, response) = try await session.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
    }
    
    func postBarHours(hours: BarHours) async throws -> BarHours {
        let endpoint = baseURL + "bar-hours/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
        }
        guard let token = try await SessionManager().authUser?.getIDToken() else {
            throw APIError.noToken
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(hours)
        
        let (data, response) = try await session.data(for: request)
        
        if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) {
            throw APIError.badRequest
        }
        
        return try decoder.decode(BarHours.self, from: data)
    }
    
    func fetchBarHours(barID: Int) async throws -> BarHours {
        let endpoint = baseURL + "bar-hours/{\(barID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
        }
        guard let token = try await SessionManager().authUser?.getIDToken() else {
            fatalError("No token found")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) {
            throw APIError.badRequest
        }
        
        return try decoder.decode(BarHours.self, from: data)
    }
    
    func fetchBarStatus(barID: Int) async throws -> BarStatus {
        let endpoint = baseURL + "bar-status/{\(barID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
        }
        guard let token = try await SessionManager().authUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) {
            throw APIError.badRequest
        }
        
        return try decoder.decode(BarStatus.self, from: data)
    }
    
    func fetchBar(barID: Int) async throws -> Bar {
        let endpoint = baseURL + "bar/{\(barID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
        }
        guard let token = try await SessionManager().authUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            throw APIError.badRequest
        }
        return try decoder.decode(Bar.self, from: data)
    }

}
