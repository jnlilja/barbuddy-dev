//
//  SearchBar.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI
import BottomSheet

struct SearchBarView: View {
    @Binding var searchText: String
    @State var prompt: String
    var position: Binding<BottomSheetPosition>?
    
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
                .simultaneousGesture(TapGesture().onEnded {
                    position?.wrappedValue = .relativeTop(1)
                })
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    @Previewable @State var searchText: String = ""
    SearchBarView(searchText: $searchText, prompt: "Enter search term")
        .padding(.horizontal)
}
