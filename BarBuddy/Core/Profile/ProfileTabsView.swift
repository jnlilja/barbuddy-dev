//
//  ProfileTabsView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/26/25.
//
import SwiftUI

struct ProfileTabsView<Content: View>: View {
    @State private var selectedTab: Int = 0
    @Namespace var animation
    @ViewBuilder let onSelect: (Int) -> Content

    var body: some View {
        let tabs = ["Photos", "Info", "Friends", "Settings"]
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                Button {
                    selectedTab = index
                } label: {
                    ZStack {
                        if selectedTab == index {
                            Capsule()
                                .foregroundStyle(.salmon)
                                .matchedGeometryEffect(id: "tab", in: animation)
                        }
                        Text(tabs[index])
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(
                                selectedTab == index ? .white : .gray
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                    }
                }
            }
        }
        .frame(width: min(UIScreen.main.bounds.width - 40, 420))
        .background(Color.white.opacity(0.1))
        .cornerRadius(25)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .animation(.smooth, value: selectedTab)

        onSelect(selectedTab)
    }
}

#Preview {
    ZStack {
        Color.darkBlue
        ProfileTabsView { _ in
            EmptyView()
        }
        .frame(width: 102, height: 40)
    }
}
