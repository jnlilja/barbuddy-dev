//
//  SearchBar.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    @State var prompt: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("Salmon"))
            
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
    SearchBar(searchText: .constant(""), prompt: "Enter search term")
        .padding(.horizontal)
}
