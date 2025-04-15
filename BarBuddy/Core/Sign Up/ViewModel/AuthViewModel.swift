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
    @Published var currentUser: User?
    
    init() {
        self.authUser = Auth.auth().currentUser
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.authUser = result.user
            print("Sign in successful")
            
        }catch{
            print("Could not sign in with error \(error.localizedDescription)")
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            self.authUser = nil
            self.currentUser = nil
            print("Logged out")
        }catch{
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
            // Store verificationID somewhere (e.g., in UserDefaults).
            // Then prompt user for the SMS verification code.
        }
    }
    
    func verifySMSCode(verificationID: String, smsCode: String) {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: smsCode
        )
    }
    
    /// Fetches the authentication confirmation document from Firestore.
      /// This request is used after the user is signed up and receives a confirmation code.
      func fetchAuthentication() async {
          do {
                      // Instead of using a shared static instance, create a fresh instance of AuthenticationService.
                      let authService = AuthenticationService()
                      let authResponse = try await authService.getAuthentication()
                      print("Authentication confirmation: \(authResponse.message)")
                      
                      // Optionally update your UI or internal state based on authResponse.
                  } catch {
                      print("Failed to fetch authentication confirmation: \(error.localizedDescription)")
                  }
              }
}


// Tells compiler that this type is safe to use in concurent programming
extension AuthDataResult: @unchecked @retroactive Sendable {}
