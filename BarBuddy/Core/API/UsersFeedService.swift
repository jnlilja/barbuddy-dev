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
    var email: String?
    var hometown: String?
    var job_or_university: String?
    var favorite_drink: String?
    var location: String?
    var profile_pictures: [String] = []
    var date_of_birth: String?
    var sexual_preference: String?
    // Convenience
    var displayName: String { "\(first_name) \(last_name)".trimmingCharacters(in: .whitespaces) }

    /// Returns the URL of the **first** picture in `profile_pictures`
    var profilePicURL: URL? {
        guard let first = profile_pictures.first else { return nil }
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
    private let baseURL = URL(string: "barbuddy-backend-148659891217.us-central1.run.app/api")!

    private init() { }

    /// GET /users – returns every user profile
    func fetchAll() async throws -> [UserProfile] {
        guard let uid = Auth.auth().currentUser else { throw UsersAPIError.noToken }
        let idToken = try await uid.getIDToken()

        //var request = URLRequest(url: baseURL.appendingPathComponent("users"))
        guard let url = URL(string: "https://barbuddy-backend-148659891217.us-central1.run.app/api/users/") else {
            return []
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let jsonData = String(data: data, encoding: .utf8) {
                print("suggestions json \(jsonData)")
            }
            
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
