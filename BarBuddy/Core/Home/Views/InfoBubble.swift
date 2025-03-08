//
//  InfoBubble.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct InfoBubble: View {
    var icon: String?
    let text: String
    
    var body: some View {
        HStack(spacing: 5) {
            if let icon = icon {
                Image(systemName: icon)
            }
            Text(text)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(Color("Salmon").opacity(0.2))
        .foregroundColor(Color("DarkPurple"))
        .cornerRadius(20)
    }
}
