//
//  AddFriends.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 2/26/25.
//

import SwiftUI

// MARK: - Add Friends View Model
class AddFriendsViewModel: ObservableObject {
    @Published var potentialFriends: [Friend] = [
        Friend(name: "Michael Brown", occupation: "Artist", profileImage: "guy1", isOut: false),
        Friend(name: "Emma Davis", occupation: "Accountant", profileImage: "guy2", isOut: true),
        Friend(name: "Olivia Green", occupation: "Photographer", profileImage: "guy3", isOut: false)
    ]
    
    @Published var acceptedFriends: [Friend] = []
    
    func acceptFriend(_ friend: Friend) {
        if let index = potentialFriends.firstIndex(where: { $0.id == friend.id }) {
            acceptedFriends.append(friend)
            potentialFriends.remove(at: index)
        }
    }
}
//  AddFriends.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 2/26/25.
//

