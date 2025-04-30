//
//  HomeView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//



import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 2
    @State private var viewModel = MapViewModel()

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
                .toolbar(.visible, for: .tabBar)
                .toolbarBackground(.darkBlue, for: .tabBar)
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(3)
        }
        .environment(viewModel)
        .tint(.salmon)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.darkBlue
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview("Home Tab Bar") {
    HomeView()
        .environmentObject(AuthViewModel())
        .environment(MapViewModel())
}
