//
//  SwipeViewModel.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/7/25.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

@MainActor
class SwipeViewModel: ObservableObject {

    // ───────────────────────────────────────── UI‑bound state
    @Published var users: [UserProfile] = []          // cards to display
    @Published var errorMessage: String?              // banner text
    @Published var bars: [Bar] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedBar: Bar? = nil
    @Published var barsSearchResult: [Bar] = []
    @Published var isFiltered = false
    @Published var filteredUsers: [UserProfile] = []

    func filterUsersByBar(_ bar: Bar, radiusKm: Double = 1.0) {
        selectedBar = bar
        isFiltered = true
        
        filteredUsers = users.filter { user in
            guard let userLocation = user.location else { return false }
            let barCoreLocation = CLLocation(latitude: bar.location.latitude, longitude: bar.location.longitude)
            let userCoreLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let distanceInMeters = barCoreLocation.distance(from: userCoreLocation)
            let distanceInKm = distanceInMeters / 1000.0
            
            return distanceInKm <= radiusKm
        }
    }
    
    func clearFilter() {
        isFiltered = false
        filteredUsers.removeAll()
    }
    
    func searchBars(query: String) -> [Bar] {
        bars.filter({ $0.name.contains(query) })
    }

    /// Refresh the swipe stack.
    func loadSuggestions() async {
        // 1.  Grab the full user feed
        do {
            
            //let results = try await Firestore.firestore().collection("Users").getDocuments()
            
            let users = try await UsersFeedService.shared.fetchAll()
            self.users = users
//            guard let currentUser = Auth.auth().currentUser else {
//                return
//            }

            // 2.  Identify “me” (match by e‑mail or uid)
//            guard
//                //let myId  = currentUser.uid,
//                let me = feed.first(where: { $0.username == username })
//            else {
//                errorMessage = "Could not determine current profile."
//                users = []
//                return
//            }
//
//            // 3.  Let MatchingService filter the feed
//            do {
//                users = try await MatchingService.shared.suggestions(for: me)
//                errorMessage = nil                                 // clear banner
//            } catch MatchingError.outOfZone {
//                users.removeAll()
//                errorMessage = "Get Closer to Match with Friends!"
//            } catch {
//                users.removeAll()
//                errorMessage = error.localizedDescription
//            }

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
//        do   { try await MatchingService.shared.sendSwipe(to: id, status: status) }
//        catch { print("⚠️ Swipe POST failed:", error.localizedDescription) }
    }
}
