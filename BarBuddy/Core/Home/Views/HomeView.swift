//
//  HomeView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//



import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0

    var body: some View {
        // Coming in future updates
        TabView(selection: $selectedTab) {
//
//            SwipeView()
//                .tabItem {
//                    Image(systemName: "person.2.fill")
//                    Text("Swipe")
//                }
//                .tag(0)
//
//            MessagesView()
//                .tabItem {
//                    Image(systemName: "message.fill")
//                    Text("Messages")
//                }
//                .tag(1)
//
            Group {
                MainFeedView()
                    .tabItem {
                        Image(systemName: "map.fill")
                        Text("Map")
                    }
                    .tint(.salmon)
                    .tag(0)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
                    .tag(1)
            }
            .toolbar(.visible, for: .tabBar)
            .toolbarBackground(.darkBlue, for: .tabBar)
        }
        .accentColor(Color("Salmon"))
    }
}

#Preview("Home View") {
    HomeView()
        .environment(MapViewModel())
        .environment(VoteViewModel())
        .environmentObject(AuthViewModel())
}
