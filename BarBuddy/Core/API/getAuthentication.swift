//
//  getAuthentication.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/15/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Model for Authentication Response
struct AuthResponse: Codable {
    let message: String
    // Extend this model with additional fields from Firestore if needed.
}

// MARK: - Service for Getting Authentication Data
final class AuthenticationService {
    private let db = Firestore.firestore()
        
        // Standard initializer (using the instance as needed).
        init() {}
        
        /// Retrieves the authentication confirmation document from Firestore.
        /// This method fetches a document (for example, with the ID "test-auth") from the "Auth" collection.
        /// - Returns: An AuthResponse model decoded from Firestore.
        func getAuthentication() async throws -> AuthResponse {
            // Adjust the collection name and document ID based on your Firestore structure.
            let docRef = db.collection("Auth").document("test-auth")
            
            // Decode the Firestore document directly into an AuthResponse instance.
            let authResponse = try await docRef.getDocument(as: AuthResponse.self)
            return authResponse
    }
}
