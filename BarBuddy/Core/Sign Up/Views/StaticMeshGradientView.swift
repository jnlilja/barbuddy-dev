//
//  AnimatedBackgroundView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/27/25.
//

import SwiftUI

struct StaticMeshGradientView: View {
    @Environment(\.colorScheme) var colorScheme
    var phase: SignUpNavigation
    var body: some View {
        if SignUpNavigation.createAccount == phase {
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0.00, 0.00], [0.50, 0.00], [1.00, 0.00],
                    [0, 0.5], [0.36, 0.26], [1.00, 0.50],
                    [0.00, 1.00], [0.20, 1.00], [1.00, 1.00],
                ], colors:
                    [
                        .darkBlue, .darkBlue, .darkBlue,
                        .salmon, .salmon, .darkBlue,
                        .darkBlue, .darkBlue, .salmon,
                    ]
            )
            .ignoresSafeArea()
        } else if SignUpNavigation.ageVerification == phase {
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0.00, 0.00], [0.50, 0.00], [1.00, 0.00],
                    [0.0, -0.5], [0.36, 0.26], [1.00, 0.50],
                    [0.00, 1.00], [0.20, 1.00], [1.00, 1.00],
                ], colors:
                    [
                        .darkBlue, .nude, .darkBlue,
                        .salmon, .salmon, .nude,
                        .darkBlue, .darkBlue, .salmon,
                    ]
            )
            .ignoresSafeArea()
        }
    }
}
#Preview {
    StaticMeshGradientView(phase: SignUpNavigation.ageVerification)
}
