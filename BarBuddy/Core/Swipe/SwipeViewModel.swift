//
//  SwipeViewModel.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/7/25.
//

import Foundation
import SwiftUI

class SwipeViewModel: ObservableObject {
    @Published var users: [User] = []
    
    init() {
        self.users = MockDatabase.getFriends()
    }
    
    func swipeLeft(user: User) {
        // Simulate ignoring the profile.
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            print("Ignored \(user.name)")
            users.remove(at: index)
        }
    }
    
    func swipeRight(user: User) {
        // Simulate sending a friend request.
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            print("Sent friend request to \(user.name)")
            users[index].friendRequested = true
            users.remove(at: index)
        }
    }
}
