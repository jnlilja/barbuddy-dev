//  BarCard.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//
import SwiftUI
import MapKit

struct BarCard: View {
    let bar: Bar
    @EnvironmentObject var viewModel: MapViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showingSwipe = false
    
    private var waitTime: String {
        viewModel.statuses.first(where: { $0.bar == bar.id })?.waitTime ?? "-"
    }
    private var crowdSize: String {
        viewModel.statuses.first(where: { $0.bar == bar.id })?.crowdSize ?? "-"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Bar Header
            HStack {
                Text(bar.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .neonPink : Color("DarkBlue"))
                Spacer()
                // Dynamic trending badge
                Trending(barName: bar.name)
            }
            // Open Hours
            Text("Open 11am – 2am")
                .foregroundColor(colorScheme == .dark ? .nude : Color("DarkPurple"))
            // Image placeholder
            Rectangle()
                .fill(Color("DarkPurple").opacity(0.3))
                .frame(height: 200)
                .cornerRadius(10)
            // Dynamic Quick‑Info Bubbles
            HStack(spacing: 12) {
                InfoTag(icon: "record.circle",        text: waitTime)
                InfoTag(icon: "person.3.fill",     text: crowdSize)
                InfoTag(icon: "dollarsign.circle", text: bar.averagePrice ?? "-")
            }
            .frame(maxWidth: .infinity)
            // Single “Meet People Here” button
            ActionButton(text: "Meet People Here", icon: "person.2.fill") {
                showingSwipe = true
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .sheet(isPresented: $showingSwipe) {
            SwipeView()
                .environmentObject(viewModel)
        }
    }
}
#Preview(traits: .sizeThatFitsLayout) {
    BarCard(bar: Bar(
        name: "Moonshine Beach",
        address: "1165 Garnet Ave, San Diego, CA 92109",
        averagePrice: "",
        latitude: 32.7980179,
        longitude: -117.2484153,
        location: "",
        usersAtBar: 0,
        currentStatus: "",
        averageRating: "",
        images: [],
        currentUserCount: "",
        activityLevel: ""
    ))
    .environmentObject(MapViewModel())
    .padding()
}


