//
//  DealsAndEvents.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

struct DealsAndEventsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFilter: DayFilter = .all
    @State private var searchText = ""
    
    // Enum for filtering by day
    enum DayFilter: String, CaseIterable {
        case all = "All"
        case sunday = "Sunday"
        case monday = "Monday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
    }
    
    // Function to filter deals and events by day
    func filterItems<T: DayFilterable>(items: [T]) -> [T] {
        if selectedFilter == .all {
            return items
        } else {
            return items.filter { $0.days.contains(selectedFilter) }
        }
    }
    
    // Function to filter items by search text
    func searchFilter<T: Searchable>(items: [T]) -> [T] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.matchesSearch(query: searchText) }
        }
    }
    
    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search Bar
                TextField("Search deals and events", text: $searchText)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top)
                    .foregroundColor(.white)
                
                // Day Filter Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(DayFilter.allCases, id: \.self) { day in
                            Button(action: {
                                selectedFilter = day
                            }) {
                                Text(day.rawValue)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedFilter == day ? Color("Salmon") : Color.white.opacity(0.2))
                                    .cornerRadius(20)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Events Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Featured Events")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            // Featured Events
                            let filteredEvents = searchFilter(items: filterItems(items: eventData))
                            
                            if filteredEvents.isEmpty {
                                Text("No events match your filter")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            } else {
                                ForEach(filteredEvents) { event in
                                    DetailedEventCard(
                                        title: event.title,
                                        location: event.location,
                                        time: event.timeDescription,
                                        description: event.daysString
                                    )
                                }
                            }
                        }
                        
                        // Deals Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Happy Hours & Deals")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            let filteredDeals = searchFilter(items: filterItems(items: dealData))
                            
                            if filteredDeals.isEmpty {
                                Text("No deals match your filter")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            } else {
                                ForEach(filteredDeals) { deal in
                                    DealCard(
                                        title: deal.title,
                                        location: deal.location,
                                        description: deal.description,
                                        days: deal.daysString
                                    )
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Map")
                    }
                    .foregroundColor(.salmon)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Deals & Events")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
}

// Protocols for filtering
protocol DayFilterable {
    var days: [DealsAndEventsView.DayFilter] { get }
    var daysString: String { get }
}

protocol Searchable {
    func matchesSearch(query: String) -> Bool
}
    
    


// SAMPLE DATA
let eventData: [Event] = [
    Event(title: "Fish Races", location: "PB Shoreclub", timeDescription: "9pm", days: [.wednesday]),
    Event(title: "College Night", location: "PB Shoreclub", timeDescription: "8pm-close", days: [.thursday]),
    Event(title: "Trivia Night", location: "PB Shoreclub", timeDescription: "7pm-10pm", days: [.tuesday]),
    Event(title: "Trivia Night", location: "PB Local", timeDescription: "7pm-9pm", days: [.wednesday]),
    Event(title: "Wine Wednesday", location: "Firehouse", timeDescription: "7pm-close", days: [.wednesday]),
    Event(title: "Karaoke Night", location: "PB Local", timeDescription: "9pm-2am", days: [.sunday]),
    Event(title: "House Thursdays", location: "PB Local", timeDescription: "9pm-2am", days: [.thursday]),
    Event(title: "DJ Night", location: "Firehouse", timeDescription: "9pm-close", days: [.sunday, .monday, .thursday, .friday]),
    Event(title: "College Night", location: "Hideaway", timeDescription: "8pm-close", days: [.thursday])
]

let dealData: [Deal] = [
    Deal(title: "Happy Hour", location: "Hideaway", description: "Discounted drinks and appetizers", days: [.sunday, .monday, .tuesday, .wednesday]),
    Deal(title: "Happy Hour", location: "PB Local", description: "$8 cocktails, $5 high noons", days: [.sunday, .friday]),
    Deal(title: "Happy Hour", location: "Beverly", description: "Half off specialty cocktails", days: [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday]),
    Deal(title: "Happy Hour", location: "Flamingo Deck", description: "$8 select cocktails and wine, $5 select drafts", days: [.monday, .tuesday, .wednesday, .thursday, .friday]),
    Deal(title: "Industry Monday", location: "PB Shoreclub", description: "$6 Herradura, Titos & High Noon\n52% OFF Industry Drink Tabs", days: [.monday]),
    Deal(title: "Tuesday Specials", location: "PB Shoreclub", description: "1/2 off select drafts\n$7 wine", days: [.tuesday]),
    Deal(title: "Wednesday Deals", location: "PB Shoreclub", description: "$6 ketel one | crown royal", days: [.wednesday]),
    Deal(title: "Thursday Specials", location: "PB Shoreclub", description: "$6 absolut | altos | jameson | kona drafts", days: [.thursday]),
    Deal(title: "College Night Special", location: "PB Shoreclub", description: "$5 WELLS & SLUSHIES", days: [.thursday]),
    Deal(title: "Sunday Special", location: "Open Bar", description: "$5 mini pitcher", days: [.sunday]),
    Deal(title: "Monday Special", location: "Open Bar", description: "$5 mini pitcher", days: [.monday]),
    Deal(title: "Tuesday Special", location: "Open Bar", description: "$5 mini pitcher", days: [.tuesday]),
    Deal(title: "Wednesday Special", location: "Open Bar", description: "$5 mini pitcher", days: [.wednesday]),
    Deal(title: "Monday Specials", location: "PB Local", description: "$8 espresso martinis, $5 wells, bottles, cans", days: [.monday]),
    Deal(title: "Wednesday Specials", location: "PB Local", description: "$6 Wells & Drafts $8 Select Apps | Prizes for 1st, 2nd & 3rd places", days: [.wednesday]),
    Deal(title: "Thursday Deals", location: "PB Local", description: "50% off wells, bottles, cans", days: [.thursday]),
    Deal(title: "Industry Night", location: "Flamingo Deck", description: "50% off drinks for industry workers", days: [.tuesday]),
    Deal(title: "Punch Bowl Special", location: "Flamingo Deck", description: "$10 off punch bowls", days: [.friday])
]

#Preview("Deals and Events") {
    NavigationStack {
        DealsAndEventsView()
    }
}
