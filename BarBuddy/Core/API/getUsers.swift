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
    static let shared = GetUserAPIService(); private init() {}

    private let baseURL = URL(
        string: "https://barbuddy-backend-148659891217.us-central1.run.app/api")!

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    func fetchAll() async throws -> [User] {
        let fbUser = try await AuthAwaiter.waitForUser()          //  Sendable now
            let token  = try await fbUser.getIDToken()

        var req = URLRequest(url: baseURL.appendingPathComponent("users/"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try decoder.decode([User].self, from: data)
    }
}

extension User {
    static let MOCK_DATA = User(id: 0, username: "user123", firstName: "Rob", lastName: "Smith", email: "mail@mail.com", password: "", dateOfBirth: "", hometown: "", jobOrUniversity: "", favoriteDrink: "", location: "", profilePictures: "string", matches: "", swipes: "", voteWeight: 1, accountType: "", sexualPreference: "", phoneNumber: "")

}
