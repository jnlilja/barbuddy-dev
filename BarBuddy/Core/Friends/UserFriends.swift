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

    @Published var friends: [GetUser] = []

    private init() { }

    func loadFriends() async {
        let result = await GetUserAPIService.shared.fetchUsers()
        switch result {
        case .success(let all):
            friends = all
        case .failure(_):
            print("error loading friends")
        }
//        let all = (try? await GetUserAPIService.shared.fetchUsers()) ?? []
//        // Placeholder: include every user for now
//        friends = all.filter { user in
//            // your real friend‑filter logic here
//            true
//        }
    }

    func addFriend(_ user: GetUser) {
        guard !friends.contains(where: { $0.id == user.id }) else { return }
        friends.append(user)
    }
}



