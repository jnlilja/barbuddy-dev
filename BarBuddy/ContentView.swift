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
        Group {
            if authViewModel.authUser != nil {
                HomeView()
                    .environment(barViewModel)
            } else {
                LoginView()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            Task {
                await barViewModel.handleScenePhaseChange(newPhase)
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
