//
//  ProgressDots.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct ProgressDots: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color("Salmon") : Color.white.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.bottom, 30)
    }
}
