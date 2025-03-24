//
//  DealsAndEventsCard.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/19/25.
//

import SwiftUI

struct EventCard: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .cornerRadius(8)
                .shadow(radius: 3)
            
            HStack {
                Text("Upcoming Events")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .symbolEffect(.wiggle.byLayer,
                                  options: .repeat(.periodic(delay: 1.0)))
                    .foregroundColor(.salmon)
                
                Text("See what's happening")
                    .font(.subheadline)
                    .foregroundColor(.salmon)
            }
            .padding()
        }
        .frame(height: 80)
    }
}

struct EventCard_Previews: PreviewProvider {
    static var previews: some View {
        EventCard()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
