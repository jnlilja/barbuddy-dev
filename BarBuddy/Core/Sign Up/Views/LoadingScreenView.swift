//
//  LoadingScreenView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/14/25.
//

import SwiftUI

struct LoadingScreenView: View {
    var body: some View {
        ZStack {
            Color(.darkBlue)
                .ignoresSafeArea()
            VStack {
                Text("Welcome!")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(.salmon)
                HStack {
                    ProgressView()
                        .tint(.white)
                    Text("Loading...")
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    LoadingScreenView()
}
