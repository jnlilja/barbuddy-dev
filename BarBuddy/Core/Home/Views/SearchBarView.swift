//
//  SearchBar.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @State var prompt: String
    
    var body: some View {
        HStack {
            if searchText.isEmpty {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.salmon)
            }
            else {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.salmon)
                    .onTapGesture { searchText = "" }
            }
            
            TextField(prompt, text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .submitLabel(.search)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))  // Changed to pure white
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    SearchBarView(searchText: .constant(""), prompt: "Enter search term")
        .padding(.horizontal)
}
