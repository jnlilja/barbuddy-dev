//
//  VotedConfirmedView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/21/25.
//
import SwiftUI

struct VoteConfirmedView: View {
    @State private var isAnimating = false
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(
                    Gradient(colors: [
                        .neonPink, colorScheme == .dark ? .darkPurple : .darkBlue,
                    ]).opacity(0.7)
                )
                .frame(width: 300, height: 110)
        
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.darkBlue)
                    .symbolEffect(.bounce, value: isAnimating)
                
                Text("Voted!")
                    .foregroundStyle(.darkBlue)
                    .cornerRadius(15)
                    .bold()
                    .font(.system(size: 60, weight: .bold, design: .rounded))
            }
        }
        .onAppear() {
            withAnimation(.easeInOut(duration: 1).delay(3)) {
                isAnimating.toggle()
            }
        }
    }
}

#Preview {
    VoteConfirmedView()
}
