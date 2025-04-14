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
            Text("Welcome!")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(.salmon)
        }
    }
}

#Preview {
    LoadingScreenView()
}
