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

        Button {
            Task {
                viewModel.signOut()
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 150, height: 50)
                    .foregroundStyle(.salmon)
                HStack {
                    // Figure walk right to left
                    Image(systemName: "figure.walk")
                        .environment(\.layoutDirection, .rightToLeft)
                    Text("Log Out")
                }
                .font(.headline)
                .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
