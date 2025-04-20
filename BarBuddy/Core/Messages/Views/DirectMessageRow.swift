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
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(radius: 5)
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
                                .frame(width: 120, height: 28)
                                .background(Color("Salmon").opacity(0.5))
                                .cornerRadius(12)
                        }
                    }
                    
                    Text(message)
                        .font(.system(size: 16))  // Larger font
                        .foregroundColor(.gray)
                }
                .frame(maxHeight: 80, alignment: .leading)
                
                Spacer()
            }
            .padding(.vertical, 15)  // More vertical padding
            .padding(.horizontal)
        }
        .frame(width: 380, height: 110)
    }
}

#Preview {
    DirectMessageRow(name: "User", message: "lol lets get drunk", location: "Riptides Pb")
}
