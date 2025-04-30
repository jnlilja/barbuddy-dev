//
//  UserAPIService.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/30/25.
//

import Foundation
import FirebaseAuth

@MainActor
final class UserAPIService {
    static let shared = UserAPIService()
    private init() {}

    private let baseURL = URL(string:
        "https://barbuddy-backend-148659891217.us-central1.run.app/api")!


    /// GET /api/users  → [User]
    func fetchAll() async throws -> [User] {
        guard let fb = Auth.auth().currentUser else { return [] }
        let token = try await fb.getIDToken()

        var req = URLRequest(url: baseURL.appendingPathComponent("users"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue(token, forHTTPHeaderField: "id-token")

        let (data, _) = try await URLSession.shared.data(for: req)
        let dec = JSONDecoder()
        dec.keyDecodingStrategy = .convertFromSnakeCase
        do{
            return try dec.decode([User].self, from: data)
        } catch {
            if let json = String(data: data, encoding: .utf8) {
                print("Raw /users payload:\n", json)
            }
            throw error
        }
        
    }
}
