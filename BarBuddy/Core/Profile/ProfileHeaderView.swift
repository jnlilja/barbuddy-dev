//
//  ProfileInfoRowView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/22/25.
//

import SwiftUI

struct ProfileHeaderView: View {
    let symbolName: String
    let headerName: String
    
    var body: some View {
        HStack {
            Image(systemName: symbolName)
                .foregroundColor(.salmon)
                .font(.system(size: 24))
            Text(headerName)
                .font(.system(size: 20))
                .foregroundColor(.darkBlue)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ProfileHeaderView(symbolName: "person.fill", headerName: "Username")
}
