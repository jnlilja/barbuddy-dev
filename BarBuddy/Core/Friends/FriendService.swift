//
//  FriendService.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/18/25.
//

// MARK: - FriendService.swift
import Foundation
import FirebaseAuth

/// Manages local state for friends and friend requests
@MainActor
class FriendService: ObservableObject {
    static let shared = FriendService()
    @Published var friends: [User] = []
    @Published var friendRequests: [User] = []

    private init() {}

    /// Load accepted friends from the server
    func loadFriends() async {
        do {
            friends = try await FriendAPIService.shared.fetchFriends()
        } catch {
            print("Error loading friends: \(error)")
            friends = []
        }
    }

    /// Load pending friend requests from the server
    func loadFriendRequests() async {
        do {
            friendRequests = try await FriendAPIService.shared.fetchPendingRequests()
        } catch {
            print("Error loading friend requests: \(error)")
            friendRequests = []
        }
    }

    /// Send a friend request to another user
    func sendFriendRequest(to user: User) async {
        guard let currentUser = Auth.auth().currentUser,
              let currentUserId = Int(currentUser.uid) else { return }
        do {
            _ = try await FriendAPIService.shared.sendFriendRequest(from: currentUserId, to: user)
            await loadFriendRequests()
        } catch {
            print("Error sending request: \(error)")
        }
    }

    /// Accept or decline a friend request
    func respond(to user: User, accept: Bool) async {
        guard let currentUser = Auth.auth().currentUser,
              let currentUserId = Int(currentUser.uid) else { return }
        do {
            let updated = try await FriendAPIService.shared.respondToFriendRequest(currentUserId: currentUserId, from: user, accept: accept)
            if accept {
                friends.append(updated)
            }
            friendRequests.removeAll { $0.id == user.id }
        } catch {
            print("Error responding to request: \(error)")
        }
    }
}
