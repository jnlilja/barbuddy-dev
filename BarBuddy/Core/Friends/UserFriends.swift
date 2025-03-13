//
//  RequestsView.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/12/25.
//

import Foundation
import SwiftUI

@MainActor
class UserFriends: ObservableObject {
    static let shared = UserFriends()
    
    @Published private var friends: [User] = []
    
    private init() { }
    
    func addFriend(_ user: User) {
        guard !friends.contains(where: { $0.id == user.id }) else { return }
        friends.append(user)
    }
    
    func getFriends() -> [User] {
        return friends
    }
}
