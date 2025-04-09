//
//  ContentView.swift
//  BarBuddy
//
//  Created by Jessica Lilja on 2/5/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.authUser == nil {
            LoginView()
        } else {
            HomeView()
        }
    }
}

// Login Flow Preview
#Preview("Content View") {
    ContentView()
        .environmentObject(AuthViewModel())
}
