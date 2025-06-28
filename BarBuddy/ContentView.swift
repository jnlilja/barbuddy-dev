//
//  ContentView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/29/25.
//

import SwiftUI

struct ContentView: View {
    @State private var barViewModel = BarViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        if authViewModel.authUser == nil {
            WelcomeView()
        } else {
            HomeView()
                .environment(barViewModel)
                .onChange(of: scenePhase) { _, newPhase in
                    Task {
                        await barViewModel.handleScenePhaseChange(newPhase)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environment(MapViewModel())
        .environment(BarViewModel())
}
