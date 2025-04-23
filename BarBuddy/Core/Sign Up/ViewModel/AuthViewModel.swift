//
//  AuthViewModel.swift
//  BarBuddy
//
//  Revised 2025‑04‑16 – Async/await Firebase Auth + REST profile integration.
//

import Foundation
@preconcurrency import FirebaseAuth   // Treat non‑Sendable Firebase types as warnings

@MainActor
final class AuthViewModel: ObservableObject {
    // MARK: - Published state
    @Published private(set) var authUser: FirebaseAuth.User?
    @Published var currentUser: User?
    
    /*  Checks to see if user has signed in previously
        which automatically signs in the user on app's
        initial launch
     
        Comment out initilizer to force "sign out"
     */
    init() {
        self.authUser = Auth.auth().currentUser
    }

    // MARK: - Sign‑in (existing account)
    func signIn(email: String, password: String) async {
        do {
            let result: AuthDataResult = try await Auth.auth().signIn(withEmail: email,
                                                                      password: password)
            authUser = result.user
            try await loadCurrentUser(email: email)
        } catch {
            print("❌ Sign‑in failed:", error.localizedDescription)
        }
    }

    // MARK: - Sign‑up (new account)
    /// Creates a Firebase Auth account and stores the profile in your backend.
    func signUp(profile: User, password: String) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: profile.email, password: password)
            authUser = result.user

            // Store profile through REST POST
            try await PostUserAPIService.shared.create(user: profile)

            try await loadCurrentUser(email: profile.email)
            print("✅ New user created & stored.")
        } catch {
            print("❌ Sign‑up failed:", error.localizedDescription)
        }
    }

    // MARK: - Sign‑out
    func signOut() {
        do {
            try Auth.auth().signOut()
            authUser = nil
            currentUser = nil
        } catch {
            print("❌ Sign‑out failed:", error.localizedDescription)
        }
    }

    // MARK: - Private helpers
    private func loadCurrentUser(email: String) async throws {
        // If your backend echoes the profile record (with id) after sign‑up,
        // you could store that id in UserDefaults, then:
        //
        // currentUser = try await GetUserAPIService.shared.fetchUser(id: savedId)
        //
        // For the moment we’ll stick with email filtering:
        let users = try await GetUserAPIService.shared.fetchUsers()
        currentUser = users.first(where: { $0.email == email })
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Async convenience for PostUserAPIService
// ─────────────────────────────────────────────────────────────────────────────

extension PostUserAPIService {
    /// Async/await wrapper around the completion‑handler version of create(user:…)
    func create(user: User) async throws {
        try await withCheckedThrowingContinuation { cont in
            self.create(user: user) { result in
                cont.resume(with: result)
            }
        }
    }
}
