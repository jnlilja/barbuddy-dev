//
//  DealCard.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/13/25.
//

import SwiftUI

struct DealCard: View {
    let title: String
    let location: String
    let description: String
    let days: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color("DarkPurple"))
                .multilineTextAlignment(.center)
            
            Text("@ \(location)")
                .font(.title3)
                .foregroundColor(Color("DarkPurple"))
            
            Text(days)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(description)
                .font(.headline)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
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
    DealCard(title: "Free Mango Cart", location: "Diry Birds", description: "Free mango cart for students", days: "Monday")
}
