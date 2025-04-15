//
//  LoginViewModel.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/15/25.
//

import Foundation
import FirebaseFirestore


@MainActor
final class LoginViewModel: ObservableObject {
    @Published var currentUser: GetApp?
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    /// Attempts to log in by querying the "Users" collection for a document with matching email and password.
    /// - Parameters:
    ///   - email: The email address provided by the user.
    ///   - password: The password provided by the user.
    /// - Returns: The matching GetApp user if found; otherwise, nil.
    func login(email: String, password: String) async throws -> GetApp? {
        let querySnapshot = try await db.collection("Users")
            .whereField("email", isEqualTo: email)
            .whereField("password", isEqualTo: password)
            .getDocuments()
        
        if let document = querySnapshot.documents.first {
            let user = try document.data(as: GetApp.self)
            self.currentUser = user
            return user
        } else {
            self.errorMessage = "No matching user found."
            return nil
        }
    }
}
