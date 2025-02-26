//
//  MainFeedView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct MainFeedView: View {
    @State private var scrollOffset: CGFloat = 0
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("DarkBlue")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Map View Section (stays at top)
                        MapPreviewSection()
                            .frame(height: 300)
                            .zIndex(1)
                        
                        // Scrollable content
                        VStack(spacing: 0) {
                            // Search Bar
                            SearchBar()
                                .padding()
                            
                            // Bar List
                            VStack(spacing: 20) {
                                ForEach(0..<5) { _ in
                                    BarCard(selectedTab: $selectedTab)
                                }
                            }
                            .padding()
                        }
                        .background(Color("DarkBlue"))
                        .offset(y: -scrollOffset)
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: proxy.frame(in: .named("scroll")).minY
                            )
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = -min(value, 0)
                }
            }
            .navigationTitle("Pacific Beach")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


#Preview("Main Feed") {
    MainFeedView(selectedTab: .constant(2))
}
