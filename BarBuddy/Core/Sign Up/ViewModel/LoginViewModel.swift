//
//  LoginViewModel.swift
//  BarBuddy
//

import Foundation
@preconcurrency import FirebaseAuth   // treat non‑Sendable Firebase symbols as warnings

// Make the type returned by Auth.signIn(...) explicitly Sendable so it can
// cross actor boundaries when using async/await.
extension AuthDataResult: @unchecked @retroactive Sendable {}

/// Lightweight helper for login screens.
/// You can use this directly or just route everything through `AuthViewModel`.
@MainActor
final class LoginViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var errorMessage = ""

    /// Attempts Firebase Auth sign‑in, then fetches the matching profile
    /// from your REST API. Returns the profile so calling views can react.
//    func login(email: String, password: String) async -> User? {
//        do {
//            // Firebase authentication
//            _ = try await Auth.auth().signIn(withEmail: email, password: password)
//
//            // Pull the profile list from your API
//            let users = try await GetUserAPIService.shared.fetchUsers()
//            if let user = users.first(where: { $0.email == email }) {
//                currentUser = user
//                return user
//            } else {
//                errorMessage = "No matching profile found."
//            }
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//        return nil
//    }
}
