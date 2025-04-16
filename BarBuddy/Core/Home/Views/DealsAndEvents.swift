//
//  DealsAndEvents.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

struct DealsAndEvents: View {
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
//    func filterItems<T: DayFilterable>(items: [T]) -> [T] {
//        if selectedFilter == .all {
//            return items
//        } else {
//            return items.filter { $0.description.contains(selectedFilter) }
//        }
//    }
    
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
                
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Events Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Featured Events")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            // Featured Events
//                            let filteredEvents = searchFilter(items: filterItems(items: eventData))
//                            
//                            if filteredEvents.isEmpty {
//                                Text("No events match your filter")
//                                    .foregroundColor(.white)
//                                    .padding()
//                                    .frame(maxWidth: .infinity)
//                            } else {
//                                ForEach(filteredEvents) { event in
//                                    DetailedEventCard(
//                                        title: event.title,
//                                        location: event.location,
//                                        time: event.timeDescription,
//                                        description: event.daysString
//                                    )
//                                }
//                            }
                        }
                        
                        // Deals Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Happy Hours & Deals")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            //let filteredDeals = searchFilter(items: filterItems(items: dealData))
                            
//                            if filteredDeals.isEmpty {
//                                Text("No deals match your filter")
//                                    .foregroundColor(.white)
//                                    .padding()
//                                    .frame(maxWidth: .infinity)
//                            } else {
//                                ForEach(filteredDeals) { deal in
//                                    DealCard(
//                                        title: deal.title,
//                                        location: deal.location,
//                                        description: deal.description,
//                                        days: deal.daysString
//                                    )
//                                }
//                            }
                        }
                        
                        // Special Promotions
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Special Promotions")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                
                            
                            
                        
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
//protocol DayFilterable {
//    var daysString: String { get }
//}

protocol Searchable {
    func matchesSearch(query: String) -> Bool
}

// Card Views
struct DetailedEventCard: View {
    let title: String
    let location: String
    let time: String
    let description: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color("DarkPurple"))
                .multilineTextAlignment(.center)
            
            Text("@ \(location)")
                .font(.title3)
                .foregroundColor(Color("DarkPurple"))
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(time)
                .font(.headline)
                .foregroundColor(Color("DarkPurple"))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal)
        .shadow(radius: 2)
    }
}

struct DealCard: View {
    let title: String
    let location: String
    let description: String
    let days: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color("DarkPurple"))
                .multilineTextAlignment(.center)
            
            Text("@ \(location)")
                .font(.title3)
                .foregroundColor(Color("DarkPurple"))
            
            Text(days)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(description)
                .font(.headline)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal)
        .shadow(radius: 2)
    }
}









// SAMPLE DATA
let eventData: [Event] = [
    Event(title: "College Night", location: "Hideaway", timeDescription: "9pm - Close", description: "", day: "Thursday"),
    Event(title: "College Night", location: "PB Shoreclub", timeDescription: "8pm - Close", description: "$5 Wells and Slushies", day: "Thursday"),
    Event(title: "Trivia Night", location: "PB Shoreclub", timeDescription: "7pm - 10pm", description: "1/2 Off Select Drafts, $7 Wine, $6 Ketel One/Crown Royal", day: "Tuesday"),
    Event(title: "Industry Monday", location: "PB Shoreclub", timeDescription: "8pm - Close", description: "$6 Herradura, Tits & High Noon, 52% OFF Industry Drink Tabs", day: "Monday"),
    Event(title: "Fish Races", location: "PB Shoreclub", timeDescription: "8pm - Close", description: "$6 absolut/altos/jameson/kona drafts", day: "Wednesday"),
    Event(title: "Live DJ", location: "PB Local", timeDescription: "9pm-2am", description: "", day: <#String#>),
    Event(title: "House Thursdays", location: "PB Local", timeDescription: "9pm-2am", description: "", day: <#String#>),
    Event(title: "DJ Night", location: "Firehouse", timeDescription: "9pm-close", description: "", day: <#String#>),
          Event(title: "College Night", location: "Hideaway", timeDescription: "8pm-close", description: "", day: <#String#>),


let dealData: [Deal] = [
    Deal(title: "Happy Hour", location: "Hideaway", timeDescription: "3pm - 6:30pm", description: "+$1 to make any cocktail double shot + double sized, +$1 to size up any beer to 32oz, ½ off shots & bottles/cans of beer", day: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]),
    Deal(title: "Wine Wednesday", location: "Firehouse", timeDescription: "7pm - Close", description: "1/2 Off Bottled Wine & Charcuterie", day: ["Wednesday"]),
    Deal(title: "Happy Hour", location: "Beverly", timeDescription: "", description: "Half off specialty cocktails", day: [""]),
    Deal(title: "Happy Hour", location: "Flamingo Deck", timeDescription: "", description: "$8 select cocktails and wine, $5 select drafts", day: [""]),
    Deal(title: "Industry Monday", location: "PB Shoreclub", timeDescription: "", description: "$6 Herradura, Titos & High Noon\n52% OFF Industry Drink Tabs", day: [""]),
    Deal(title: "Tuesday Specials", location: "PB Shoreclub", timeDescription: "", description: "1/2 off select drafts\n$7 wine", day: [""]),
    Deal(title: "Wednesday Deals", location: "PB Shoreclub", timeDescription: "", description: "$6 ketel one | crown royal", day: [""]),
    Deal(title: "Monday Special", location: "Open Bar", timeDescription: "", description: "$5 mini pitcher", day: [""]),
    Deal(title: "Tuesday Special", location: "Open Bar", timeDescription: "", description: "$5 mini pitcher", day: [""]),
    Deal(title: "Wednesday Special", location: "Open Bar", timeDescription: "", description: "$5 mini pitcher", day: [""]),
    Deal(title: "Monday Specials", location: "PB Local", timeDescription: "", description: "$8 espresso martinis, $5 wells, bottles, cans", day: [""]),
    Deal(title: "Wednesday Specials", location: "PB Local", timeDescription: "", description: "$6 Wells & Drafts $8 Select Apps | Prizes for 1st, 2nd & 3rd places", day: [""]),
    Deal(title: "Thursday Deals", location: "PB Local", timeDescription: "", description: "50% off wells, bottles, cans", day: [""]),
    Deal(title: "Industry Night", location: "Flamingo Deck", timeDescription: "", description: "50% off drinks for industry workers", day: [""]),
    Deal(title: "Punch Bowl Special", location: "Flamingo Deck", timeDescription: "", description: "$10 off punch bowls", day: [""])]


#Preview("Deals and Events") {
    NavigationStack {
        DealsAndEvents()
    }
}
