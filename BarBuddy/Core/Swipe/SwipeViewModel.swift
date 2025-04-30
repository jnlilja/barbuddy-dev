//
//  SwipeViewModel.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/7/25.
//

import Foundation
import FirebaseAuth
import SwiftUI

@MainActor
final class SwipeViewModel: ObservableObject {

    @Published var users: [User] = []
    @Published var errorMessage: String?

    // ───────────────────── init
    init() {
        // retry every time Firebase auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, _ in
            Task { await self?.loadSuggestions() }
        }
        // first attempt
        Task { await loadSuggestions() }
    }

    // ───────────────────── refresh
    func loadSuggestions() async {
        do {
            let feed = try await GetUserAPIService.shared.fetchAll()

            guard
                let email = Auth.auth().currentUser?.email?.lowercased(),
                let me    = feed.first(where: { $0.email.lowercased() == email })
            else { users = []; errorMessage = "No profile found."; return }

            users = try await MatchingService.shared.suggestions(for: me)
            errorMessage = users.isEmpty ? "No nearby matches right now." : nil
        } catch {
            users = []
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Swipes
    func swipeLeft(profile: User) {
        guard let pid = profile.id else { return }
        withAnimation { users.removeAll { $0.id == pid } }
        Task { await postSwipe(pid, status: .dislike) }
    }

    func swipeRight(profile: User) {
        guard let pid = profile.id else { return }
        withAnimation { users.removeAll { $0.id == pid } }
        Task { await postSwipe(pid, status: .like) }
    }

    private func postSwipe(_ id: Int, status: SwipeStatus) async {
        try? await MatchingService.shared.sendSwipe(to: id, status: status)
    }
}
