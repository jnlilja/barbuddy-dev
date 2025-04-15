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
        _ = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: smsCode
        )
    }
    
    func createUser(data: SignUpViewModel) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: data.email, password: data.password)
            self.authUser = result.user
            let user = User(id: UUID().uuidString, name: data.name, age: data.age, height: data.height, hometown: data.hometown, school: data.school, favoriteDrink: data.favoriteDrink, preference: data.preference, smoke: data.smoke, bio: "Hello", imageNames: [])
            self.currentUser = user
            //let encodedUser = try Firestore.Encoder().encode(user)
            //try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            
            print("User created successfully")
            print(data)
        }catch{
            print(error.localizedDescription)
        }
    }
    
}

// Tells compiler that this type is safe to use in concurent programming
extension AuthDataResult: @unchecked @retroactive Sendable {}
