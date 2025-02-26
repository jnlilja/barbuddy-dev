//
//  BarListSection.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct BarListSection: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<5) { _ in
                    BarCard(selectedTab: .constant(0))
                }
            }
            .padding()
        }
    }
}
