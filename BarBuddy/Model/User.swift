//
//  User.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/7/25.
//

import Foundation

struct User: Identifiable, Decodable, Hashable {
    let id: UUID = UUID()
    let name: String
    let age: Int
    let height: String
    let hometown: String
    let school: String
    let favoriteDrink: String
    let preference: String
    let bio: String
    let imageNames: [String]
    
    // Indicates if a friend request was sent.
    var friendRequested: Bool = false
}
