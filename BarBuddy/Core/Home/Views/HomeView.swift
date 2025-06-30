//
//  HomeView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 2
    @State private var mapViewModel = MapViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
//            Tab("Swipe", systemImage: "person.fill.checkmark.and.xmark", value: 0) {
//                SwipeView()
//            }
//            
//            Tab("Messages", systemImage: "message.fill", value: 1) {
//                MessagesView()
//            }
            
            Tab("Map", systemImage: "map.fill", value: 2) {
                MapView()
                    .toolbarBackground(.darkBlue, for: .tabBar)
                    .toolbarBackground(.visible, for: .tabBar)
            }
            
//            Tab("Profile", systemImage: "person.circle.fill", value: 3) {
//                ProfileView()
//            }
        }
        .environment(mapViewModel)
        .tint(.salmon)
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}

#if DEBUG
#Preview("Home View") {
    HomeView()
        .environment(MapViewModel())
        .environmentObject(AuthViewModel())
        .environment(BarViewModel.preview)
}
#endif
