//
//  DealsAndEventsCard.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/19/25.
//

import SwiftUI

struct DealsAndEventsButtonView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            Color(.secondarySystemBackground)
                .cornerRadius(8)
                .shadow(radius: 3)
            
            VStack(spacing: 8.0) {
                Text("Deals and Events")
                    .font(.system(size: 30))
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .dark ? .white : .darkBlue)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 3.0) {
                    Text("See what's happening")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(.salmon)
                    
                    Image(systemName: "arrow.right")
                        .symbolEffect(.wiggle.byLayer,
                                      options: .repeat(.periodic(delay: 1.0)))
                        .foregroundColor(.salmon)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
        .frame(height: 100.0)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    DealsAndEventsButtonView()
}
