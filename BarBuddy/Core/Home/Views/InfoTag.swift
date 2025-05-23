//
//  InfoTag.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct InfoTag: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.white)
            Text(text)
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .font(.system(size: 14))
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color("DarkPurple"))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color("NeonPink"), lineWidth: 1)
        )
        .cornerRadius(15)
    }
}

#Preview {
    InfoTag(icon: "star", text: "Sample Text")
        .padding()
        
}
