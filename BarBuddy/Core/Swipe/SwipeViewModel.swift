//
//  SwipeViewModel.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/7/25.
//

import Foundation
import SwiftUI

@MainActor
final class SwipeViewModel: ObservableObject {
    @Published var users: [UserProfile] = []
    @Published var errorMessage: String?
    
    init() {
        Task { await loadUsers() }
    }
    
    // Pull every profile from the backend
    func loadUsers() async {
        do {
            users = try await UsersFeedService.shared.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Swipe actions
    func swipeLeft(profile: UserProfile) {
        users.removeAll { $0.id == profile.id }   // ignored
    }
    
    func swipeRight(profile: UserProfile) {
        // TODO: POST friend‑request endpoint when available
        users.removeAll { $0.id == profile.id }
    }
}
