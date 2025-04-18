//
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
    @State private var showingSwipe = false        // ← renamed state

    // Find this bar’s index in the static array
    private var idx: Int {
        viewModel.bars.firstIndex(where: { $0.id == bar.id }) ?? -1
    }

    // Dynamic values from the view model
    private var musicType: String {
        viewModel.music[idx] ?? "–"
    }
    private var crowdSize: String {
        viewModel.statuses[idx]?.crowd_size ?? "–"
    }
    private var priceRange: String {
        viewModel.pricing[idx] ?? "–"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Bar Header
            HStack {
                Text(bar.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .neonPink : Color("DarkBlue"))
                Spacer()
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color("NeonPink"))
                    Text("Trending")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .nude : Color("DarkPurple"))
                }
            }

            // Open Hours
            Text("Open 11am – 2am")
                .foregroundColor(colorScheme == .dark ? .nude : Color("DarkPurple"))

            // Image placeholder
            Rectangle()
                .fill(Color("DarkPurple").opacity(0.3))
                .frame(height: 200)
                .cornerRadius(10)

            // Dynamic Quick‑Info Bubbles
            HStack(spacing: 12) {
                InfoTag(icon: "music.note",        text: musicType)
                InfoTag(icon: "person.3.fill",     text: crowdSize)
                InfoTag(icon: "dollarsign.circle", text: priceRange)
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
            // Present the main swipe screen
            SwipeView()
                .environmentObject(viewModel)
                // AuthViewModel is inherited from above
        }
    }
}

struct BarCard_Previews: PreviewProvider {
    static var previews: some View {
        BarCard(bar: Bar(
            name: "Hideaway",
            location: CLLocationCoordinate2D(latitude: 32.7961859,
                                             longitude: -117.2558475)
        ))
        .environmentObject(MapViewModel())
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
