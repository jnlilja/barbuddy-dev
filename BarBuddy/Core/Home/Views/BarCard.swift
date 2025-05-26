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
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Bar Header
            HStack {
                Text(bar.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .neonPink : Color("DarkBlue"))
                Spacer()
                // Dynamic trending badge
                //Trending(barName: bar.name)
            }
            // Open Hours
//            Text("Open 11am – 2am")
//                .foregroundColor(colorScheme == .dark ? .nude : Color("DarkPurple"))
            Text(bar.address)
                  .foregroundColor(colorScheme == .dark ? .nude : Color("DarkPurple"))
            // Image placeholder
            
            if let firstImage = bar.images.first, let imageURL = URL(string: firstImage.image) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_):
                        Rectangle()
                            .fill(Color("DarkPurple").opacity(0.3))
                            .frame(height: 200)
                            .cornerRadius(10)
                    case .empty:
                        ZStack {
                            Rectangle()
                                .fill(Color("DarkPurple").opacity(0.3))
                                .frame(height: 200)
                                .cornerRadius(10)
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Rectangle()
                    .fill(Color("DarkPurple").opacity(0.3))
                    .frame(height: 200)
                    .cornerRadius(10)
            }
            // Dynamic Quick‑Info Bubbles
            HStack(spacing: 12) {
                //InfoTag(icon: "music.note",        text: viewModel.music[index] ?? "–")
                //InfoTag(icon: "person.3.fill",     text: viewModel.statuses[index]?.crowd_size ?? "–")
                InfoTag(icon: "person.3.fill",     text: bar.waitTime ?? "-")
                InfoTag(icon: "dollarsign.circle", text: bar.average_price)
            }
            .frame(maxWidth: .infinity)
            // Single “Meet People Here” button
//            ActionButton(text: "Meet People Here", icon: "person.2.fill") {
//                showingSwipe = true
//            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
        .cornerRadius(15)
        .shadow(radius: 5)
//        .sheet(isPresented: $showingSwipe) {
//            SwipeView()
//                .environmentObject(viewModel)
//        }
    }
    // Helper to find this bar’s index
    private var index: Int {
        viewModel.bars.firstIndex(where: { $0.id == bar.id }) ?? -1
    }
}

//struct BarCard_Previews: PreviewProvider {
//    static var previews: some View {
//        BarCard(bar: Bar(
//            name: "Hideaway",
//            location: CLLocationCoordinate2D(latitude: 32.7961859,
//                                             longitude: -117.2558475)
//        ))
//        .environmentObject(MapViewModel())
//        .previewLayout(.sizeThatFits)
//        .padding()
//    }
//}

