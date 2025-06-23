//
//  HomeView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 1
    @State private var mapViewModel = MapViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Map", systemImage: "map.fill", value: 1) {
                MainFeedView()
                    .toolbarBackground(.visible, for: .tabBar)
                    .toolbarBackground(.darkBlue, for: .tabBar)
            }
        }
        .environment(mapViewModel)
        .tint(.salmon)
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
