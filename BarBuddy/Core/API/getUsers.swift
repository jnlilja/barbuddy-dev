//
//  getUsers.swift
//  BarBuddy
//
//  Updated 2025‑04‑16 – REST GET /users using Firebase idToken
//

import SwiftUI
import FirebaseAuth

// TODO: Update to use async/await and remove completion-style methods

// MARK: - Model matching server response
struct GetUser: Codable, Identifiable, Hashable {
    var id: Int
    var username: String
    var first_name: String
    var last_name: String
    var date_of_birth: String?
    var email: String?
    var password: String?
    var hometown: String?
    var job_or_university: String?
    var favorite_drink: String?
    var location: String?
    var profile_pictures: [String] = []
    var matches: [String] = []
    var swipes: [String] = []
    var vote_weight: Int = 0
    var account_type: String = ""
    var sexual_preference: String?
}
