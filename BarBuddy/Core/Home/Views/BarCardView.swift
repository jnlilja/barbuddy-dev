//  BarCard.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI
import MapKit
import SDWebImageSwiftUI

struct BarCardView: View {
    let bar: Bar
    @State private var hours: String?
    @Environment(MapViewModel.self) var viewModel
    @Environment(BarViewModel.self) var barViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.displayScale) var displayScale
    @State private var loading = true
    
    private var waitTime: String? {
        barViewModel.statuses.first(where: { $0.bar == bar.id })?
            .waitTime
            .replacingOccurrences(of: "-", with: " - ")
            .replacingOccurrences(of: "<", with: "< ")
            .replacingOccurrences(of: ">", with: "> ")
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
                .lineLimit(1)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .white : .darkBlue)
            
            // Open Hours
            Text(hours ?? "Hours unavailable")
                .foregroundColor(colorScheme == .dark ? .salmon : .darkPurple)
            // Image placeholder
            if let barImageURL = bar.images.first?.image {
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
                                if let hours, hours.contains("Closed") {
                                    Text("Closed")
                                } else if let waitTime = waitTime {
                                    Text(waitTime)
                                } else {
                                    Text("Unavailable")
                                }
                            }
                            .foregroundStyle(colorScheme == .dark ? .nude : .white)
                            .font(.title)
                            .bold()
                        }
                    }
                }
                .foregroundColor(.white)
                
                NavigationLink(destination: BarDetailView(bar: bar)
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
            guard let index = barViewModel.hours.firstIndex(where: { $0.bar == bar.id }) else {
                loading = false
                return
            }
            hours = barViewModel.formatBarHours(hours: &barViewModel.hours[index])
            loading = false
        }
        .padding()
        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
        .cornerRadius(15)
        .shadow(radius: 5)
        
    }
}

#if DEBUG
#Preview(traits: .sizeThatFitsLayout) {
    NavigationStack {
        BarCardView(bar: Bar.sampleBar)
            .environment(MapViewModel())
            .padding()
    }
    .environment(BarViewModel.preview)
}
#endif
