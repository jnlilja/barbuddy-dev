//
//  FriendAPIService.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/18/25.
//

// MARK: - FriendAPIService.swift
import Foundation
import FirebaseAuth

/// Handles all friend-related API calls with Firebase Auth
class FriendAPIService: @unchecked Sendable {
    @MainActor static let shared = FriendAPIService()
    private let baseURL = "http://127.0.0.1:8000/api"

    /// Attaches Firebase ID token to the request headers
    private func authorizedRequest(url: URL, method: String = "GET", body: Data? = nil) async throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Fetch Firebase ID token for the current user
        guard let user = Auth.auth().currentUser else {
            throw URLError(.userAuthenticationRequired)
        }
        let token = try await user.getIDTokenResult().token
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        if let body = body {
            request.httpBody = body
        }
        return request
    }
    

    /// Sends a friend request from the current user to another user
    func sendFriendRequest(from currentUserId: Int, to user: GetUser) async throws -> GetUser {
        guard let url = URL(string: "\(baseURL)/\(currentUserId)/send_friend_request/") else {
            throw URLError(.badURL)
        }
        let body = try JSONEncoder().encode(user)
        let request = try await authorizedRequest(url: url, method: "POST", body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(GetUser.self, from: data)
    }

    /// Responds to a pending friend request (accept or decline)
    // MARK: — Request payload for responding to a friend request
    private struct RespondFriendRequestBody: Codable {
        let accept: Bool
        let user_id: Int
    }

    func respondToFriendRequest(
      currentUserId: Int,
      from user: GetUser,
      accept: Bool
    ) async throws -> GetUser {
        // Build URL
        guard let url = URL(string: "\(baseURL)/\(currentUserId)/respond_friend_request/") else {
            throw URLError(.badURL)
        }
        // Encode homogeneous payload
        let bodyObject = RespondFriendRequestBody(accept: accept, user_id: user.id)
        let bodyData = try JSONEncoder().encode(bodyObject)

        // Attach Firebase auth header & send
        let request = try await authorizedRequest(
            url: url,
            method: "POST",
            body: bodyData
        )
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(GetUser.self, from: data)
    }


    /// Fetches the current user's friends
    func fetchFriends() async throws -> [GetUser] {
        guard let currentUser = Auth.auth().currentUser,
              let url = URL(string: "\(baseURL)/\(currentUser.uid)/friends/") else {
            throw URLError(.badURL)
        }
        let request = try await authorizedRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([GetUser].self, from: data)
    }

    /// Fetches pending friend requests for the current user
    func fetchPendingRequests() async throws -> [GetUser] {
        guard let currentUser = Auth.auth().currentUser,
              let url = URL(string: "\(baseURL)/\(currentUser.uid)/requests/") else {
            throw URLError(.badURL)
        }
        let request = try await authorizedRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([GetUser].self, from: data)
    }
}


