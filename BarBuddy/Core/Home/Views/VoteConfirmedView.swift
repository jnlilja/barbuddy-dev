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
                    .symbolEffect(.bounce.up.byLayer, value: isAnimating)
                
                Text("Voted!")
                    .foregroundStyle(.darkBlue)
                    .cornerRadius(15)
                    .bold()
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .phaseAnimator(VotedAnimationPhase.allCases, trigger: isAnimating) { content, phase in
                        content
                            .scaleEffect(phase.scale)
                    } animation: { phase in
                        switch phase {
                        case .up: .snappy(duration: 0.3)
                        default: .snappy(duration: 0.2)
                        }
                    }
            }
        }
        .onAppear {
            withAnimation {
                isAnimating.toggle()
            }
        }
    }
}

#Preview {
    VoteConfirmedView()
}


