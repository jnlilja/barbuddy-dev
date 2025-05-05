//
//  HomeView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//



import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 2
    @StateObject private var viewModel = MapViewModel()

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
            // Set tab bar appearance to white with slight transparency
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor.white.withAlphaComponent(0.95)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview("Home Tab Bar") {
    HomeView()
        .environmentObject(SessionManager())
        .environmentObject(MapViewModel())
}
