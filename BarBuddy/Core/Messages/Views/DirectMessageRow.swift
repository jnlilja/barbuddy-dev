//
//  DirectMessageRow.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct DirectMessageRow: View {
    let name: String
    let message: String
    let location: String?
    
    var body: some View {
        HStack(spacing: 20) {  // Increased spacing
            // Profile image
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)  // Larger circle
            
            VStack(alignment: .leading, spacing: 8) {  // Increased spacing
                HStack {
                    Text(name)
                        .font(.system(size: 20, weight: .bold))  // Larger font
                        .foregroundColor(Color("DarkPurple"))
                    
                    if let location = location {
                        Text("@ \(location)")
                            .font(.system(size: 16))  // Larger font
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color("Salmon").opacity(0.5))
                            .cornerRadius(12)
                    }
                }
                
                Text(message)
                    .font(.system(size: 16))  // Larger font
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 15)  // More vertical padding
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}
