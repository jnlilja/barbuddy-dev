//
//  AuthViewModel.swift
//  BarBuddy
//
//  Revised 2025‑04‑16 – Async/await Firebase Auth + REST profile integration.
//

//Test@123dev

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

enum SessionState {
    case loggedIn, loggedOut, splash
}

@MainActor
class SessionManager: ObservableObject {
    
    @Published private(set) var authUser: FirebaseAuth.User?
    @Published var currentUser: GetUser?
    @Published var showErrorAlert = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var sessionState: SessionState = .loggedOut
    
    init() {
        let isRunningInPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if !isRunningInPreview {
            if FirebaseApp.allApps == nil {
                FirebaseApp.configure()
            }
            if Auth.auth().currentUser != nil {
                sessionState = .splash
                Task {
                    await fetchLoggedInUser()
                }
            } else {
                signOut()
                sessionState = .loggedOut
            }
        }
    }
    
    private func fetchLoggedInUser() async {
        let result = await GetUserAPIService.shared.getUser()
        isLoading = false
        switch result {
        case .success(let user):
            currentUser = user
            sessionState = .loggedIn
        case .failure(_):
            signOut()
            sessionState = .loggedOut
        }
    }

    // MARK: - Sign‑in (existing account)
    func signIn(email: String, password: String) async {
        isLoading = true
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.authUser = result.user
            await fetchLoggedInUser()
            //authUser = result.user
            //try await loadCurrentUser(email: email)
        } catch {
            isLoading = false
            errorMessage = "Sign In Failed. Please try again"
            showErrorAlert = true
            print("❌ Sign‑in failed:", error.localizedDescription)
        }
    }

    // MARK: - Sign‑up (new account)
    /// Creates a Firebase Auth account and stores the profile in your backend.
    func signUp(profile: SignUpUser) async {
        isLoading = true
        do {
            let result = await PostUserAPIService.shared.register(user: profile)
            switch result {
            case .success(let success):
                let idToken = success.firebase_token
                let authUser = try await Auth.auth().signIn(withCustomToken: idToken)
                self.authUser = authUser.user
                print("✅ New user signed in.")
                await fetchLoggedInUser()
                //try await loadCurrentUser(email: profile.email)
                
            case .failure(_):
                print("an error occured during sign up")
                return
            }
        }
        catch let apiError as APIError {
            isLoading = false
            switch apiError {
            case .badURL:
                print("Invalid server endpoint.")
            case .noToken:
                print("No authentication token received.")
            case .transport(let underlying):
                print("Network error: \(underlying.localizedDescription)")
            case .encoding(let underlying):
                print("Encoding error: \(underlying.localizedDescription)")
            case .decoding(let underlying):
                 print("Decoding error: \(underlying.localizedDescription)")
            default:
                print("Sign up error")
            }
            errorMessage = "We encountered an error signing you up. Please try again later."
            showErrorAlert = true
        }
        catch let nsError as NSError where nsError.domain == AuthErrorDomain {
            isLoading = false
            let code = AuthErrorCode(rawValue: nsError.code)
            switch code {
            case .invalidEmail:
                errorMessage = "Email address is badly formatted."
            case .weakPassword:
                errorMessage = "Your password is too weak."
            case .emailAlreadyInUse:
                errorMessage = "Email is already in use."
            default:
                print(nsError.localizedDescription)
                errorMessage = "We encountered an error signing you up. Please try again later."
                showErrorAlert = true
            }
        }
        catch {
            isLoading = false
            errorMessage = "We encountered an error signing you up. Please try again later."
            showErrorAlert = true
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
//    private func loadCurrentUser(email: String) async throws {
//        // If your backend echoes the profile record (with id) after sign‑up,
//        // you could store that id in UserDefaults, then:
//        //
//        // currentUser = try await GetUserAPIService.shared.fetchUser(id: savedId)
//        //
//        // For the moment we’ll stick with email filtering:
//        do {
//            let users = try await GetUserAPIService.shared.fetchUsers()
//            currentUser = users.first(where: { $0.email == email })
//        } catch {
//            
//        }
//        
//    }
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
