//
//  DealsAndEvents.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

// MARK: - Searchable Protocol
protocol Searchable {
    func matchesSearch(query: String) -> Bool
}

// MARK: - View
struct DealsAndEventsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var serverDate: Date = Date()
    @Environment(BarViewModel.self) private var barViewModel

    // Compute weekday from serverDate
    private var todayName: String {
        let df = DateFormatter()
        df.locale = Locale.current
        df.dateFormat = "EEEE"
        return df.string(from: serverDate)
    }

    private var filteredEvents: [BarEvent] {
        BarEvent.allEvents.filter { event in
            event.day.contains(todayName)
                && event.matchesSearch(query: searchText)
        }
    }

    private var filteredDeals: [BarDeal] {
        BarDeal.allDeals.filter { deal in
            deal.day.contains(todayName)
                && deal.matchesSearch(query: searchText)
        }
    }

    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()

            VStack {
                SearchBarView(searchText: $searchText, prompt: "Search by title, location, or description")
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 30) {
                        if !filteredEvents.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Today's Events")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                ForEach(filteredEvents) { event in
                                    DetailsCardView(
                                        title: event.title,
                                        location: event.location,
                                        time: event.timeDescription,
                                        description: event.description
                                    )
                                }
                            }
                        }

                        if !filteredDeals.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Happy Hours & Deals")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                ForEach(filteredDeals) { deal in
                                    DetailsCardView(
                                        title: deal.title,
                                        location: deal.location,
                                        time: deal.timeDescription,
                                        description: deal.description
                                    )
                                }
                            }
                        }

                        if filteredEvents.isEmpty && filteredDeals.isEmpty {
                            Text(
                                "No deals or events available for \(todayName)."
                            )
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Deals & Events")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview("Deals and Events") {
    NavigationStack {
        DealsAndEventsView()
            .environment(BarViewModel())
    }
}
