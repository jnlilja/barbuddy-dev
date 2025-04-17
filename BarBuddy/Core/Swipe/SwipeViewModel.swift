//
//  SwipeViewModel.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/7/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class SwipeViewModel: ObservableObject {

    // ───────────────────────────────────────── UI‑bound state
    @Published var users: [UserProfile] = []          // cards to display
    @Published var errorMessage: String?              // banner text

    // Inject the global auth model from your App file:
    @EnvironmentObject var authVM: AuthViewModel

    // ───────────────────────────────────────── Initial load
    init() {
        Task { await loadSuggestions() }
    }

    /// Refresh the swipe stack.
    func loadSuggestions() async {
        // 1.  Grab the full user feed
        do {
            let feed = try await UsersFeedService.shared.fetchAll()

            // 2.  Identify “me” (match by e‑mail or uid)
            guard
                let myEmail  = authVM.authUser?.email,
                let me       = feed.first(where: { $0.email == myEmail })
            else {
                errorMessage = "Could not determine current profile."
                users        = []
                return
            }

            // 3.  Let MatchingService filter the feed
            do {
                users = try await MatchingService.shared.suggestions(for: me)
                errorMessage = nil                                 // clear banner
            } catch MatchingError.outOfZone {
                users.removeAll()
                errorMessage = "Get Closer to Match with Friends!"
            } catch {
                users.removeAll()
                errorMessage = error.localizedDescription
            }

        } catch {
            // Network / decoding failure while pulling the feed
            users.removeAll()
            errorMessage = error.localizedDescription
        }
    }

    // ───────────────────────────────────────── Swipe actions
    func swipeLeft(profile: UserProfile) {
        users.removeAll { $0.id == profile.id }           // ignored locally
        Task { await tryPostSwipe(id: profile.id, status: .dislike) }
    }

    func swipeRight(profile: UserProfile) {
        users.removeAll { $0.id == profile.id }           // liked locally
        Task { await tryPostSwipe(id: profile.id, status: .like) }
    }

    // Helper that swallows network errors (prints to console only)
    private func tryPostSwipe(id: Int, status: SwipeStatus) async {
        do   { try await MatchingService.shared.sendSwipe(to: id, status: status) }
        catch { print("⚠️ Swipe POST failed:", error.localizedDescription) }
    }
}
