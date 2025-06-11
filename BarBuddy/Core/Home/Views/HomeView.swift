//
//  HomeView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
    @State private var mapViewModel = MapViewModel()
    var body: some View {
        TabView(selection: $selectedTab) {
            Group {
                MainFeedView()
                    .tabItem {
                        Image(systemName: "map.fill")
                        Text("Map")
                    }
                    .tag(0)
                
                EmptyView()
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Coming Soon")
                    }
                    .sensoryFeedback(.selection, trigger: selectedTab)
                    .tag(1)
            }
            .toolbar(.visible, for: .tabBar)
            .toolbarBackground(.darkBlue, for: .tabBar)
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
