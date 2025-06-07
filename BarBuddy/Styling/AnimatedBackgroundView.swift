//
//  AnimatedBackgroundView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/27/25.
//

import SwiftUI

struct AnimatedBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var appear = false
    @State private var appear2 = false

    var body: some View {
        if colorScheme == .light {
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0.00, 0.00], [appear2 ? 0.80 : 0.50, 0.00], [1.00, 0.00],
                    [0.00, appear2 ? 0.20 : 0.50],
                    appear2 ? [0.70, 0.79] : [0.36, 0.26], [1.00, appear2 ? 0.85 : 0.50],
                    [0.00, 1.00], [appear ? 0.80 : 0.20, 1.00], [1.00, 1.00],
                ],
                colors: [
                    appear ? .darkPurple : .darkBlue,
                    appear ? .nude : .darkBlue,
                    appear2 ? .darkPurple : .darkBlue,
                    appear ? .darkBlue : .salmon,
                    appear2 ? .nude : .salmon,
                    appear2 ? .salmon : .darkBlue,
                    appear2 ? .darkPurple : .darkBlue,
                    appear ? .salmon : .darkBlue,
                    appear2 ? .darkPurple : .salmon,
                ]
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2).repeatForever(autoreverses: true)
                ) {
                    appear.toggle()
                }
                
                withAnimation(
                    .easeInOut(duration: 5).repeatForever(autoreverses: true)
                ) {
                    appear2.toggle()
                }
            }
            .ignoresSafeArea()
        } else {
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0.00, 0.00], [appear2 ? 0.80 : 0.50, 0.00], [1.00, 0.00],
                    [0.00, appear2 ? 0.20 : 0.50],
                    appear2 ? [0.70, 0.79] : [0.36, 0.26], [1.00, appear2 ? 0.85 : 0.50],
                    [0.00, 1.00], [appear ? 0.80 : 0.20, 1.00], [1.00, 1.00],
                ],
                colors: [
                    .darkBlue,
                    appear ? .nude : .darkBlue,
                    .darkBlue,
                    appear ? .darkBlue : .salmon,
                    appear2 ? .nude : .salmon,
                    appear2 ? .salmon : .darkBlue,
                    .darkBlue,
                    appear ? .salmon : .darkBlue,
                    .salmon,
                ]
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2).repeatForever(autoreverses: true)
                ) {
                    appear.toggle()
                }
                
                withAnimation(
                    .easeInOut(duration: 5).repeatForever(autoreverses: true)
                ) {
                    appear2.toggle()
                }
            }
            .ignoresSafeArea()
        }
    }
}
#Preview {
    AnimatedBackgroundView()
}
