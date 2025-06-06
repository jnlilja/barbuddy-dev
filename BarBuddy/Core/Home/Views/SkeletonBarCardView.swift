//
//  SkeletonBarCardView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/6/25.
//

import SwiftUI
import Shimmer

struct SkeletonBarCardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private var screenWidth: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen.bounds.width ?? 390
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Bar Header
            Text("A")
                .font(.system(size: 32, weight: .bold))
                .hidden()
            
            Rectangle()
                .fill(Color("DarkPurple").opacity(0.3))
                .frame(height: 200)
                .cornerRadius(10)
            
            HStack(spacing: 5) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.darkBlue)
                        .frame(width: screenWidth - 170, height: 80)
                    
                    VStack(spacing: 5) {
                        Text("Est. Line Wait time")
                            .font(.system(size: 14, weight: .bold))
                        Text("Closed")
                    }
                    .hidden()
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.darkBlue)
                        .frame(height: 80)
                    
                    VStack(spacing: 5) {
                        Text("Wrong?")
                            .font(.system(size: 14, weight: .medium))
                        
                        Text("Vote Wait Time >")
                            .multilineTextAlignment(.center)
                            .frame(width: 80)
                            .bold()
                    }
                    .hidden()
                }
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .shimmering()
    }
}

#Preview {
    ZStack {
        Color.darkBlue.opacity(0.9)
        SkeletonBarCardView()
    }
}
