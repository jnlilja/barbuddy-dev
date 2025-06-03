//
//  AuthViewModel.swift
//  BarBuddy
//
//  Revised 2025‑04‑16 – Async/await Firebase Auth + REST profile integration.
//

//Test@123dev

import Foundation
@preconcurrency import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var authUser: FirebaseAuth.User?
    @Published var currentUser: GetUser?
    @Published var showingAlert = false
    @Published private var errorMessage = ""
    
    init() {
        self.authUser = Auth.auth().currentUser
    }
    
    // MARK: - Sign‑in (existing account)
    func signIn(email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.authUser = result.user
        } catch {
            print("❌ Sign‑in failed:", error.localizedDescription)
        }
    }
    
    // MARK: - Sign‑up (new account)
    /// Creates a Firebase Auth account and stores the profile in your backend.
    func signUp(profile: SignUpUser) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: profile.email, password: profile.password)
            self.authUser = result.user
        } catch let nsError as NSError where nsError.domain == AuthErrorDomain {
            // Handle Firebase Auth errors
            switch AuthErrorCode(rawValue: nsError.code) {
            case .emailAlreadyInUse:
                errorMessage = "Email is already in use."
            case .networkError:
                errorMessage = "Network error occurred. Please try again."
            default:
                errorMessage = "Sign‑up failed: \(nsError.localizedDescription)"
            }
        } catch {
            // Handle other errors
            errorMessage = "Sign‑up failed: \(error.localizedDescription)"
        }
    }
    
    // Overloaded signUp method for email and password
    func signUp(email: String, password: String) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.authUser = result.user
        } catch let nsError as NSError where nsError.domain == AuthErrorDomain {
            // Handle Firebase Auth errors
            switch AuthErrorCode(rawValue: nsError.code) {
            case .emailAlreadyInUse:
                errorMessage = "Email is already in use."
            case .networkError:
                errorMessage = "Network error occurred. Please try again."
            default:
                errorMessage = "Sign‑up failed: \(nsError.localizedDescription)"
            }
        } catch {
            // Handle other errors
            errorMessage = "Sign‑up failed: \(error.localizedDescription)"
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
    
    func getErrorMessage() -> String {
        return errorMessage
    }
}
