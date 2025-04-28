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
    @Published var currentUser: GetUser?
    
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
    func signUp(profile: PostUser, password: String) async {
        do {
            // 1. Create Firebase user
            let result = try await Auth.auth().createUser(withEmail: profile.email, password: password)
            authUser = result.user
            
            // 2. Get a fresh token and wait for it to propagate
            let token = try await result.user.getIDToken()
            print("✅ Got Firebase token after signup")
            
            // Add a small delay to ensure token propagation
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            // 3. Store profile through REST POST
            try await PostUserAPIService.shared.create(user: profile)
            
            // 4. Load the current user
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
        currentUser = try await GetUserAPIService.shared.fetchUserByEmail(email: email)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Async convenience for PostUserAPIService
// ─────────────────────────────────────────────────────────────────────────────

extension PostUserAPIService {
    /// Async/await wrapper around the completion‑handler version of create(user:…)
    func create(user: PostUser) async throws {
        try await withCheckedThrowingContinuation { cont in
            self.create(user: user) { result in
                cont.resume(with: result)
            }
        }
    }
}
