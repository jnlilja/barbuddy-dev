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
    static let MOCK_DATA = User(id: 0, username: "user123", firstName: "Rob", lastName: "Smith", email: "mail@mail.com", password: "", dateOfBirth: "", hometown: "", jobOrUniversity: "", favoriteDrink: "", location: "", profilePictures: [ProfilePictures(image: "", isPrimary: true, uploadedAt: "")], matches: [Match(id: 1, user1: 1, user1Details: MatchUser(id: 4, username: "", profilePicture: ""), user2: 7, user2Details: MatchUser(id: 0, username: "", profilePicture: ""), status: "", createdAt: "", disconnectedBy: 1, disconnectedByUsername: "")], swipes: [Swipe(id: 1, swiperUsername: "", swipedOn: 0, status: "", timestamp: "")], voteWeight: 1, accountType: "", sexualPreference: "", phoneNumber: "")

}
