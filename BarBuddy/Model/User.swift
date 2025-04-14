//
//  User.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/7/25.
//

import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var age: Int
    var height: String
    var hometown: String
    var school: String
    var favoriteDrink: String
    var preference: String
    var smoke: [SmokePreference]
    var bio: String
    var imageNames: [String]
    var username: String = ""
    var email: String = ""
    
    // Indicates if a friend request was sent.
    var friendRequested: Bool = false
}
