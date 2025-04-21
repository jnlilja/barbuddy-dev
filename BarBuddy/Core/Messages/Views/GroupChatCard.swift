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
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(radius: 5)
            HStack(spacing: 20) {  // Increased spacing
                // Group member images
                ZStack {
                    ForEach(memberImages.indices, id: \.self) { index in
                        if !memberImages[index].isEmpty {
                            Image(systemName: memberImages[index])
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .offset(x: CGFloat(index * 25))
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 50)  // Larger circles
                                .offset(x: CGFloat(index * 25))  // Adjusted offset
                        }
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
                .frame(width: 250,height: 72, alignment: .leading)
            }
        }
        .frame(width: 380, height: 110)
    }
}

#Preview {
    NavigationStack {
        List {
            Section("Group Chats") {
                
                GroupChatCard(groupName: "The Drunks", message: "Was wondering if anyone wants to join me at Hideaway next week?", memberImages: ["", "", ""])
            }
        }
        .listStyle(.plain)
    }
}
