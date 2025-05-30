//
//  ContentView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/29/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View {
        if authViewModel.authUser != nil {
            HomeView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
