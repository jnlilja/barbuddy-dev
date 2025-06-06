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


    func addFriend(_ user: GetUser) {
        guard !friends.contains(where: { $0.id == user.id }) else { return }
        friends.append(user)
    }
}



