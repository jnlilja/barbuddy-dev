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
    
    private var hours: String {
        guard let hours = viewModel.hours.first(where: { $0.bar == bar.id }),
              let open = hours.openTime,
              let closed = hours.closeTime
        else {
            return "Hours Unavailable"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return "\(dateFormatter.string(from: open)) - \(dateFormatter.string(from: closed))"
    }
    
    private var waitTime: String {
        viewModel.statuses.first(where: { $0.bar == bar.id })?.formattedWaitTime ?? "N/A"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(bar.name)
                    .lineLimit(2)
                    .foregroundStyle(colorScheme == .dark ? .nude : .darkBlue)
                    .font(.headline)
                
                Text(hours)
                    .foregroundStyle(colorScheme == .dark ? .white: .darkPurple)
            }

            Spacer()

            Text(waitTime)
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
