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
                .font(.system(size: 32, weight: .bold, design: .default))
                .foregroundColor(.salmon)
        }
    }
}

#Preview {
    LoadingScreenView()
}
