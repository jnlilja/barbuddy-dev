//
//  RequestsView.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/12/25.
//

import Foundation

@MainActor
class UserFriends: ObservableObject {
    static let shared = UserFriends()

    @Published var friends: [User] = []

    private init() { }

    func loadFriends() async {
//        let all = (try? await GetUserAPIService.shared.fetchUsers()) ?? []
//        // Placeholder: include every user for now
//        friends = all.filter { user in
//            // your real friend‑filter logic here
//            true
//        }
    }

    func addFriend(_ user: User) {
        guard !friends.contains(where: { $0.id == user.id }) else { return }
        friends.append(user)
    }
}



