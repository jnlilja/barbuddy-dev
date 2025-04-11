//
//  SettingsView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/10/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        NavigationStack {
            Button {
                Task {
                    try viewModel.signOut()
                }
            }label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 150, height: 50)
                        .foregroundStyle(.salmon)
                    HStack {
                        Image(systemName: "door.left.hand.open")
                        Text("Log Out")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
