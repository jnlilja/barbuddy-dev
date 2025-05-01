//
//  AuthViewModel.swift
//  BarBuddy
//
//  Revised 2025‑04‑16 – Async/await Firebase Auth + REST profile integration.
//

import Foundation
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    // MARK: - Published state
    @Published var authUser: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        self.authUser = Auth.auth().currentUser
        //Task { await fetchData() }
    }

    // MARK: - Sign‑in (existing account)
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            authUser = result.user
            //await fetchData()
            print("Sign‑in successful!")
            
        } catch {
            print("❌ Sign‑in failed:", error.localizedDescription)
        }
    }

    // MARK: - Sign‑up (new account)
    /// Creates a Firebase Auth account and stores the profile in your backend.
    func signUp(profile: CreateUserRequest) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: profile.email, password: profile.password)
            self.authUser = result.user

            // Store profile through REST POST and fetch the user
            self.currentUser = try await NetworkManager.shared.postUser(user: profile)
            print("✅ New user created & stored.")
        } catch APIError.badURL {
            print("❌ Sign‑up failed: Invalid URL.")
        } catch APIError.encoding {
            print( "❌ Sign‑up failed: Failed to encode user data.")
        } catch NetworkError.decodingFailed {
            print("❌ Sign‑up failed: Failed to decode server response.")
        } catch APIError.noToken {
            print( "❌ Sign‑up failed: No token returned.")
        } catch NetworkError.httpError {
            print("❌ Sign‑up failed: HTTP error.")
        } catch NetworkError.invalidData {
            print("Invalid data returned from the server.")
        } catch {
            print("❌ Sign‑up failed bruh:", error.localizedDescription)
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
//    private func fetchData() async {
//        do {
////            guard let uid = Auth.auth().currentUser?.uid else { print("No user logged in."); return }
////            self.currentUser = try await NetworkManager.shared.getUser(id: uid)
//        } catch {
//            print("❌ Failed to fetch user data.")
//        }
//    }

    
}
