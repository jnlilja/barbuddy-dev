//
//  DetailsCardView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/13/25.
//

import SwiftUI

// Card Views
struct DetailsCardView: View {
    let title: String
    let location: String
    let time: String
    let description: String
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .white : .darkPurple)
                .multilineTextAlignment(.center)

            Text("@ \(location)")
                .font(.title3)
                .foregroundColor(colorScheme == .dark ? .salmon : .darkPurple)
                .multilineTextAlignment(.center)

            Text(description)
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .nude : .gray)
                .multilineTextAlignment(.center)

            Text(time)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .salmon : .darkPurple)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .padding(.horizontal)
        .shadow(radius: 2)
    }
}

#Preview {
    DetailsCardView(
        title: "Happy Hour",
        location: "Hideaway",
        time: "9pm",
        description: "All drinks half off"
    )
}
