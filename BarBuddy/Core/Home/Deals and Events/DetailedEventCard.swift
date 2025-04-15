//
//  DetailedEventCard.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/13/25.
//

import SwiftUI

// Card Views
struct DetailedEventCard: View {
    let title: String
    let location: String
    let time: String
    let description: String

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color("DarkPurple"))
                .multilineTextAlignment(.center)

            Text("@ \(location)")
                .font(.title3)
                .foregroundColor(Color("DarkPurple"))

            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)

            Text(time)
                .font(.headline)
                .foregroundColor(Color("DarkPurple"))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal)
        .shadow(radius: 2)
    }
}

#Preview {
    DetailedEventCard(
        title: "Happy Hour",
        location: "Hideaway",
        time: "9pm",
        description: "All drinks half off"
    )
}
