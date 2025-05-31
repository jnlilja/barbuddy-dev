//  BarCard.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//
import SwiftUI
import MapKit
import SDWebImageSwiftUI

struct BarCard: View {
    let bar: Bar
    @State private var hours: String?
    @Environment(MapViewModel.self) var viewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(VoteViewModel.self) var voteViewModel
    @Environment(\.displayScale) var displayScale
    @State private var loading = true
    
    private var waitTime: String? {
        viewModel.statuses.first(where: { $0.bar == bar.id })?.waitTime ?? ""
    }
    
    private var screenWidth: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen.bounds.width ?? 390
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            // Bar Header
            Text(bar.name)
                .minimumScaleFactor(0.5)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .neonPink : Color("DarkBlue"))
            
            // Open Hours
            Text(hours ?? "Hours unavailable")
                .foregroundColor(colorScheme == .dark ? .nude : Color("DarkPurple"))
            // Image placeholder
            if let barImageURL = bar.images?.first?.image {
                WebImage(url: URL(string: barImageURL))
                    .resizable()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            else{
                Rectangle()
                    .fill(Color("DarkPurple").opacity(0.3))
                    .frame(height: 200)
                    .cornerRadius(10)
            }
            HStack(spacing: 5) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.darkBlue)
                        .frame(width: screenWidth - 170, height: 80)
                    
                    VStack(spacing: 5) {
                        Text("Est. Line Wait time")
                            .font(.system(size: 14, weight: .bold))
                        if loading {
                            ProgressView()
                                .tint(.white)
                        }
                        else {
                            Group {
                                if hours == nil {
                                    Text("Unavailable")
                                } else if let hours, hours.contains("Closed") {
                                    Text("Closed")
                                } else if let waitTime, !waitTime.isEmpty {
                                    Text(waitTime)
                                } else {
                                    Text("No votes yet")
                                }
                            }
                            .font(.title)
                            .bold()
                        }
                    }
                }
                .foregroundColor(.white)
                
                NavigationLink(destination: BarDetailPopup(bar: bar)
                    .environment(voteViewModel)
                    .environment(viewModel)) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.darkBlue)
                                .frame(height: 80)
                            
                            VStack(spacing: 5) {
                                Text("Wrong?")
                                    .font(.system(size: 14, weight: .medium))
                                
                                Text("Vote Wait Time >")
                                    .multilineTextAlignment(.center)
                                    .frame(width: 80)
                                    .bold()
                            }
                        }
                        .foregroundColor(.white)
                    }
            }
        }
        .onAppear {
            guard var currentHours = viewModel.hours.first(where: { $0.bar == bar.id }) else {
                loading = false
                return
            }
            hours = bar.formatBarHours(hours: &currentHours)
            loading = false
        }
        .padding()
        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
        .cornerRadius(15)
        .shadow(radius: 5)
        
    }
}
#Preview(traits: .sizeThatFitsLayout) {
    NavigationStack {
        BarCard(bar: Bar(
            name: "Moonshine Beach",
            address: "1165 Garnet Ave, San Diego, CA 92109",
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
        .environment(MapViewModel())
        .environment(VoteViewModel())
        .padding()
    }
}


