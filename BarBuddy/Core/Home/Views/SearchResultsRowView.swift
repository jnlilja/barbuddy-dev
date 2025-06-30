//
//  SearchResultsRowView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/17/25.
//

import SwiftUI

struct SearchResultsRowView: View {
    @Environment(BarViewModel.self) var viewModel
    @Environment(\.colorScheme) var colorScheme
    let bar: Bar
    
    private var hours: BarHours? {
        guard let hours = viewModel.hours.first(where: { $0.bar == bar.id }),
            hours.openTime != nil,
            hours.closeTime != nil
        else { return nil }
        return hours
    }
    
    private var waitTime: String {
        viewModel.statuses.first(where: { $0.bar == bar.id })?.formattedWaitTime ?? "N/A"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(bar.name)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(colorScheme == .dark ? .nude : .darkBlue)
                    .font(.headline)
                
                Text(hours?.displayHours ?? "Hours unavailable")
                    .foregroundStyle(colorScheme == .dark ? .white: .darkPurple)
            }

            Spacer()
            
            if let isClosed = hours?.isClosed {
                Text(!isClosed ? waitTime : "Closed")
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedCorner(radius: 10))
    }
}

#if DEBUG
#Preview {
    SearchResultsRowView(
        bar: Bar(
            id: 1,
            name: "Coin-Op",
            address: "",
            averagePrice: "",
            location: Location(latitude: 0, longitude: 0),
            usersAtBar: [],
            currentStatus: CurrentStatus(crowdSize: nil, waitTime: nil, lastUpdated: nil),
            averageRating: nil,
            images: [BarImage(image: "", caption: nil)],
            currentUserCount: 2,
            activityLevel: ""
        )
    )
    .background()
    .shadow(radius: 5)
    .environment(BarViewModel.preview)
}
#endif
