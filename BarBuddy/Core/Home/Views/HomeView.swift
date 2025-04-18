//
//  HomeView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 2

    var body: some View {
        TabView(selection: $selectedTab) {
            SwipeView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Swipe")
                }
                .tag(0)

            MessagesView()
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

            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(Color("Salmon"))
        .onAppear {
            // Set tab bar to be white with transparency
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor.white.withAlphaComponent(0.95)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// Preview with the necessary environment objects:
// - AuthViewModel for ProfileView
// - MapViewModel for SwipeView / MainFeedView
#Preview("Home Tab Bar") {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(MapViewModel())
}
