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

    @State private var crowdSize    = "empty"
    @State private var waitTime     = "<5 min"
    @State private var showingDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ───────── Bar Header
            HStack {
                Text(bar.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(colorScheme == .dark
                                     ? .neonPink
                                     : Color("DarkBlue"))
                Spacer()
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color("NeonPink"))
                    Text("Trending")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(colorScheme == .dark
                                         ? .nude
                                         : Color("DarkPurple"))
                }
            }

            // ───────── Dynamic Status
            Text("Crowd: \(crowdSize)")
                .foregroundColor(colorScheme == .dark
                                 ? .nude
                                 : Color("DarkPurple"))
            Text("Wait: \(waitTime)")
                .foregroundColor(colorScheme == .dark
                                 ? .nude
                                 : Color("DarkPurple"))

            // ───────── Open Hours
            Text("Open 11am – 2am")
                .foregroundColor(colorScheme == .dark
                                 ? .nude
                                 : Color("DarkPurple"))

            // ───────── Bar Image Placeholder
            Rectangle()
                .fill(Color("DarkPurple").opacity(0.3))
                .frame(height: 200)
                .cornerRadius(10)

            // ───────── Quick Info Icons
            HStack(spacing: 12) {
                InfoTag(icon: "music.note", text: "House")
                InfoTag(icon: "person.3.fill", text: "Packed")
                InfoTag(icon: "dollarsign.circle", text: "$5‑20")
            }
            .frame(maxWidth: .infinity)

            // ───────── Action Buttons
            VStack(spacing: 10) {
                ActionButton(
                    text: "See who's there",
                    icon: "person.2.fill"
                ) {
                    showingDetail = true
                }
                ActionButton(
                    text: "Check the line",
                    icon: "antenna.radiowaves.left.and.right"
                ) {
                    showingDetail = true
                }
            }
        }
        .padding()
        .background(colorScheme == .dark
                    ? Color(.secondarySystemBackground)
                    : .white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            BarDetailPopup(name: bar.name)
                .tint(.salmon)
        }
        // ───────── Status Wiring
        .onAppear { updateStatus() }
        .onChange(of: viewModel.statuses) { _ in updateStatus() }
    }

    private func updateStatus() {
        // find the index of this bar in the MapViewModel list
        if let idx = viewModel.bars.firstIndex(where: { $0.id == bar.id }),
           let status = viewModel.statuses[idx] {
            crowdSize = status.crowd_size
            waitTime  = status.wait_time
        }
    }
}

struct BarCard_Previews: PreviewProvider {
    static var previews: some View {
        BarCard(bar: Bar(
            //id: 1,
            name: "Hideaway",
            location: CLLocationCoordinate2D(
                latitude: 32.7961859,
                longitude: -117.2558475
            )
        ))
        .environmentObject(MapViewModel())
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
