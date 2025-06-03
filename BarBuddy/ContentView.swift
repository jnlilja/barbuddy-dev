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
    var body: some View {
        if authViewModel.authUser != nil {
            HomeView()
                .environment(barViewModel)
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environment(MapViewModel())
        .environment(BarViewModel())
}
