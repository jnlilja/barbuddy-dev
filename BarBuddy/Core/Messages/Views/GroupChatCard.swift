//
//  GroupChatCard.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct GroupChatCard: View {
    let groupName: String
    let message: String
    let memberImages: [String]
    
    var body: some View {
        HStack(spacing: 20) {  // Increased spacing
            // Group member images
            ZStack {
                ForEach(memberImages.indices, id: \.self) { index in
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)  // Larger circles
                        .offset(x: CGFloat(index * 25))  // Adjusted offset
                }
            }
            .frame(width: 100, alignment: .leading)  // Wider frame
            
            VStack(alignment: .leading, spacing: 8) {  // Increased spacing
                Text(groupName)
                    .font(.system(size: 20, weight: .bold))  // Larger font
                    .foregroundColor(Color("DarkPurple"))
                
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
