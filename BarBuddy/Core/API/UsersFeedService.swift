//
//  UsersFeedService.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/16/25.
//

import Foundation
import FirebaseAuth
import UIKit       // only for optional image helper

// MARK: - Decodable model that matches the /users JSON
struct UserProfile: Identifiable, Codable, Hashable {
    let id: Int
    let username: String
    let first_name: String
    let last_name: String
    let email: String
    let hometown: String
    let job_or_university: String
    let favorite_drink: String
    let location: String
    let profile_pictures: [String: String]?
    let date_of_birth: String
    let sexual_preference: String
    // Convenience
    var displayName: String { "\(first_name) \(last_name)".trimmingCharacters(in: .whitespaces) }

    /// Returns the URL of the **first** picture in `profile_pictures`
    var profilePicURL: URL? {
        guard let first = profile_pictures?.values.first else { return nil }
        return URL(string: first)
    }
}

enum UsersAPIError: Error, LocalizedError {
    case noToken
    case transport(Error)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .noToken:           return "Missing Firebase idToken."
        case .transport(let e):  return e.localizedDescription
        case .decoding(let e):   return "Decoding error: \(e.localizedDescription)"
        }
    }
}

// MARK: - Network Service
@MainActor
final class UsersFeedService {
    static let shared = UsersFeedService()

    /// Replace with your real base URL, **without** the trailing “/users”.
    private let baseURL = URL(string: "https://YOUR_API_BASE_URL")!

    private init() { }

    /// GET /users – returns every user profile
    func fetchAll() async throws -> [UserProfile] {
        guard let uid = Auth.auth().currentUser else { throw UsersAPIError.noToken }
        let idToken = try await uid.getIDToken()

        var request = URLRequest(url: baseURL.appendingPathComponent("users"))
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode([UserProfile].self, from: data)
        } catch let e as DecodingError {
            throw UsersAPIError.decoding(e)
        } catch {
            throw UsersAPIError.transport(error)
        }
    }

    /// Convenience helper to turn a `profilePicURL` into a `UIImage`.
    func loadImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        return image
    }
}
