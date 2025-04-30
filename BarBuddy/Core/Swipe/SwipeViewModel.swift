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

    init() { Task { await loadSuggestions() } }

    // MARK: - Refresh
    func loadSuggestions() async {
        do {
            let feed = try await UserAPIService.shared.fetchAll()

            guard
                let email = Auth.auth().currentUser?.email?.lowercased(),
                let me    = feed.first(where: { $0.email.lowercased() == email })
            else {
                errorMessage = "Could not determine your profile."
                users.removeAll(); return
            }

            users = try await MatchingService.shared.suggestions(for: me)
            errorMessage = users.isEmpty ? "No nearby matches – try later." : nil

        } catch {
            users.removeAll()
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
