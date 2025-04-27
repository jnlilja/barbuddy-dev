//
//  getUsers.swift
//  BarBuddy
//
//  Updated 2025‑04‑16 – REST GET /users using Firebase idToken
//

import SwiftUI
import FirebaseAuth

// MARK: Still A WORK IN PROGRESS
// MARK: - Network service
@MainActor
final class GetUserAPIService {
    static let shared = GetUserAPIService()
}

// MARK: - ViewModel
@MainActor
final class UsersViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var errorMessage = ""
    @Published var showingError = false

}

extension User {
    static let MOCK_DATA = User(id: 0, username: "user123", firstName: "Rob", lastName: "Smith", email: "mail@mail.com", password: "", dateOfBirth: "", hometown: "", jobOrUniversity: "", favoriteDrink: "", location: Location(latitude: 10, longitude: 10), profilePictures: [ProfilePicture(id: 0, url: "", isPrimary: true, uploadedAt: "")], matches: "", swipes: "", voteWeight: 1, accountType: "", sexualPreference: "")

}
