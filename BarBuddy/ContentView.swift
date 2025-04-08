//
//  ContentView.swift
//  BarBuddy
//
//  Created by Jessica Lilja on 2/5/25.
//

import SwiftUI

struct ContentView: View {
  
    @State private var showingLoginScreen = false
    var mapViewModel = MapViewModel()
    
    // Skip the login/sign up views when set to true
    private let skipToHome = false

    var body: some View {
        if !skipToHome {
            if !showingLoginScreen {
                LoginView(showingLoginScreen: $showingLoginScreen)
            }
            else {
                HomeView()
                    .environmentObject(mapViewModel)
                    .transition(.move(edge: .trailing))
            }
        } else {
            HomeView()
                .environmentObject(mapViewModel)
        }
    }
}

// Login Flow Preview
#Preview("Content View") {
    ContentView()
        .environmentObject(MapViewModel())
}
