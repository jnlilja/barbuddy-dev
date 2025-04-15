//
//  AuthViewModel.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/28/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var authUser: FirebaseAuth.User?
    // Updated currentUser type to GetApp? to store Firestore user details.
    @Published var currentUser: GetApp?
    
    init() {
        self.authUser = Auth.auth().currentUser
    }
    
    /// Signs in the user by calling FirebaseAuth and, if desired, then fetching additional Firestore user details.
    /// This example uses LoginViewModel to fetch the matching Firestore user.
    func signIn(email: String, password: String) async throws {
        do {
            // First perform FirebaseAuth sign in.
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.authUser = result.user
            print("Firebase sign in successful")
            
            // Now query Firestore for the matching user details via LoginViewModel.
            let loginVM = LoginViewModel()
            if let firestoreUser = try await loginVM.login(email: email, password: password) {
                self.currentUser = firestoreUser
                print("Firestore user found: \(firestoreUser.username)")
            } else {
                print("No matching Firestore user found.")
            }
            
        } catch {
            print("Could not sign in with error \(error.localizedDescription)")
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            self.authUser = nil
            self.currentUser = nil
            print("Logged out")
        } catch {
            print("Could not logout with error \(error.localizedDescription)")
        }
    }
    
    func startPhoneNumberAuth(phoneNumber: String) {
        // Example: +1 555-555-1234
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    print("Verification error: \(error.localizedDescription)")
                    return
                }
                // Store verificationID as needed.
            }
    }
    
    func verifySMSCode(verificationID: String, smsCode: String) {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: smsCode
        )
        // Implement further sign-in using the SMS credential if needed.
    }
    
    /// Fetches the authentication confirmation document from Firestore.
    /// This method is used after sign-up when the user receives a confirmation code.
    func fetchAuthentication() async {
        do {
            let authService = AuthenticationService()
            let authResponse = try await authService.getAuthentication()
            print("Authentication confirmation: \(authResponse.message)")
        } catch {
            print("Failed to fetch authentication confirmation: \(error.localizedDescription)")
        }
    }
}

// Tells the compiler that this type is safe to use in concurrent contexts.
extension AuthDataResult: @unchecked @retroactive Sendable {}
