//
//  AuthAwaiter.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/30/25.
//

import Foundation
import FirebaseAuth

// ₁  Let actors treat FirebaseAuth.User as Sendable
extension FirebaseAuth.User: @unchecked Sendable {}

enum AuthAwaiter {

    /// Suspends until FirebaseAuth already has—or restores—a user session.
    @preconcurrency
    static func waitForUser() async throws -> FirebaseAuth.User {

        if let u = Auth.auth().currentUser { return u }

        return try await withCheckedThrowingContinuation { cont in
            // ₂  We intentionally ignore the returned handle to avoid
            //    capturing a non-Sendable value inside this closure.
            _ = Auth.auth().addStateDidChangeListener { _, user in
                if let user {
                    cont.resume(returning: user)
                }
            }
        }
    }
}
