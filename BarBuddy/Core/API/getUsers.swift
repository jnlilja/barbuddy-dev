//
//  getUsers.swift
//  BarBuddy
//
//  Updated 2025‑04‑16 – REST GET /users using Firebase idToken
//

import SwiftUI
import Foundation
import FirebaseAuth

@MainActor
final class GetUserAPIService {
    static let shared = GetUserAPIService()
    private init() {}

    private let baseURL = URL(
        string: "https://barbuddy-backend-148659891217.us-central1.run.app/api")!

    /// GET /api/users  → [User]
    func fetchAll() async throws -> [User] {
        // 1) make sure we have a Firebase user
        guard let fbUser = Auth.auth().currentUser else { return [] }
        let token = try await fbUser.getIDToken()

        // 2) build request with the ONE header backend accepts
        var req = URLRequest(url: baseURL.appendingPathComponent("users"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // 3) fire + decode
        let (data, _) = try await URLSession.shared.data(for: req)
        let dec = JSONDecoder()
        dec.keyDecodingStrategy = .convertFromSnakeCase     // snake_case → camelCase
        return try dec.decode([User].self, from: data)
    }
}

extension User {
    static let MOCK_DATA = User(id: 0, username: "user123", firstName: "Rob", lastName: "Smith", email: "mail@mail.com", password: "", dateOfBirth: "", hometown: "", jobOrUniversity: "", favoriteDrink: "", location: "", profilePictures: "string", matches: "", swipes: "", voteWeight: 1, accountType: "", sexualPreference: "", phoneNumber: "")

}
