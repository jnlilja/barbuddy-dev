//
//  HomeView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @State private var selectedTab = 2
    @StateObject private var viewModel = MapViewModel()

    /// Numeric backend ID for the signed‑in user
    @State private var currentUserID: Int? = nil
    @State private var isLoadingUserID = true

    var body: some View {
        TabView(selection: $selectedTab) {
            SwipeView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Swipe")
                }
                .tag(0)

            // Messages tab: show loader until we have an ID
            Group {
                if let userID = currentUserID {
                    MessagesView(currentUserID: userID)
                } else if isLoadingUserID {
                    ZStack {
                        Color.darkBlue
                            .ignoresSafeArea()
                        ProgressView("Loading Messages…")
                            .foregroundColor(.white)
                    }
                } else {
                    ZStack {
                        Color.darkBlue
                            .ignoresSafeArea()
                        Text("Unable to load Messages")
                            .foregroundColor(.white)
                    }
                }
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Messages")
            }
            .tag(1)

            MainFeedView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
                .tag(2)
                .environmentObject(viewModel)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(Color("Salmon"))
        .onAppear {
            // Tab bar styling
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor.white.withAlphaComponent(0.95)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .task {
            await fetchCurrentUserID()
        }
    }

    /// Fetch backend user list, match on Firebase UID, store numeric ID
    private func fetchCurrentUserID() async {
        guard let firebaseUID = Auth.auth().currentUser?.uid else {
            isLoadingUserID = false
            return
        }
        do {
            let users = try await GetUserAPIService.shared.fetchUsers()
            if let me = users.first(where: { $0.username == firebaseUID }) {
                currentUserID = me.id
            }
        } catch {
            print("⚠️ fetchCurrentUserID error: \(error)")
        }
        isLoadingUserID = false
    }
}

#Preview("Home Tab Bar") {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(MapViewModel())
}

