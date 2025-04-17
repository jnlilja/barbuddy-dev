//
//  DealsAndEvents.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

struct DealsAndEventsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Search Bar
                TextField("Search deals and events", text: $searchText)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top)
                    .foregroundColor(.white)

                ScrollView {
                    VStack(spacing: 30) {
                        // Events Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Featured Events")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }

                        // Deals Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Happy Hours & Deals")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }

                        // Special Promotions
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Special Promotions")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Map")
                    }
                    .foregroundColor(.salmon)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("Deals & Events")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
    
    // Function to filter items by search text
    func searchFilter<T: Searchable>(items: [T]) -> [T] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.matchesSearch(query: searchText) }
        }
    }
}

protocol Searchable {
    func matchesSearch(query: String) -> Bool
}

#Preview("Deals and Events") {
    NavigationStack {
        DealsAndEventsView()
    }
}
