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

// MARK: - Models
struct BarEvent: Identifiable, Searchable {
    let id = UUID()
    let title: String
    let location: String
    let timeDescription: String
    let description: String
    let day: [String]

    func matchesSearch(query: String) -> Bool {
        query.isEmpty ||
        title.localizedCaseInsensitiveContains(query) ||
        location.localizedCaseInsensitiveContains(query) ||
        description.localizedCaseInsensitiveContains(query)
    }
}

struct BarDeal: Identifiable, Searchable {
    let id = UUID()
    let title: String
    let location: String
    let timeDescription: String
    let description: String
    let day: [String]

    func matchesSearch(query: String) -> Bool {
        query.isEmpty ||
        title.localizedCaseInsensitiveContains(query) ||
        location.localizedCaseInsensitiveContains(query) ||
        description.localizedCaseInsensitiveContains(query)
    }
}

// MARK: - Sample Data
let sampleEvents: [BarEvent] = [
    BarEvent(title: "College Night", location: "Hideaway", timeDescription: "9pm - Close", description: "2 for $9 Cocktails, $2.25 Red Bull w/ Cocktail", day: ["Thursday"]),
    BarEvent(title: "College Night", location: "PB Shoreclub", timeDescription: "8pm - Close", description: "$5 Wells and Slushies", day: ["Thursday"]),
    BarEvent(title: "College Night", location: "Hideaway", timeDescription: "9pm - Close", description: "2 for $9 Cocktails, $2.25 Red Bull w/ Cocktail", day: ["Thursday"]),
        BarEvent(title: "College Night", location: "PB Shoreclub", timeDescription: "8pm - Close", description: "$5 Wells and Slushies", day: ["Thursday"]),
        BarEvent(title: "Trivia Night", location: "PB Shoreclub", timeDescription: "7pm - 10pm", description: "1/2 Off Select Drafts, $7 Wine, $6 Ketel One/Crown Royal", day: ["Tuesday"]),
        BarEvent(title: "Industry Monday", location: "PB Shoreclub", timeDescription: "8pm - Close", description: "$6 Herradura, Tits & High Noon, 52% OFF Industry Drink Tabs", day: ["Monday"]),
        BarEvent(title: "Fish Races", location: "PB Shoreclub", timeDescription: "8pm - Close", description: "$6 absolut/altos/jameson/kona drafts", day: ["Wednesday"]),
        BarEvent(title: "Live DJs", location: "Firehouse", timeDescription: "12pm - Close", description: "", day: ["Sunday", "Saturday"]),
        BarEvent(title: "Live Music", location: "Firehouse", timeDescription: "6pm", description: "", day: ["Wednesday"]),
        BarEvent(title: "Live DJs", location: "Firehouse", timeDescription: "9pm - Close", description: "", day: ["Thursday"]),
        BarEvent(title: "Solset DJs", location: "Firehouse", timeDescription: "5pm - Close", description: "", day: ["Friday"]),
        BarEvent(title: "Karaoke", location: "PB Local", timeDescription: "9pm - 2am", description: "$8 Espresso Martinis, $5 Wells, Bottles, Cans", day: ["Wednesday"]),
        BarEvent(title: "Trivia", location: "PB Local", timeDescription: "7pm - 9pm", description: "$6 Wells & Drafts, $8 Select Apps, Prizes for 1st, 2nd & 3rd places", day: ["Thursday"]),
        BarEvent(title: "Industry Tuesday", location: "Flamingo Deck", timeDescription: "", description: "50% off drinks for industry workers", day: ["Tuesday"]),
        BarEvent(title: "Trivia", location: "Mavericks", timeDescription: "7pm - 9pm", description: "$4 select beers, hard teas, and shots", day: ["Wednesday"]),
        BarEvent(title: "Karaoke", location: "710", timeDescription: "8pm", description: "Mimosa flight $25, frozen slushie flight $16, colossal bloody mary $19 ALL UNTIL 2pm", day: ["Sunday"]),
        BarEvent(title: "Live Band", location: "710", timeDescription: "9pm", description: "Mimosa flight $25, frozen slushie flight $16, colossal bloody mary $19 ALL UNTIL 2pm", day: ["Saturday"]),
        BarEvent(title: "Beer Pong", location: "710", timeDescription: "", description: "$7.10 ALL drinks", day: ["Monday"]),
        BarEvent(title: "Trivia", location: "710", timeDescription: "7pm", description: "2 for 1 tequila shots, $7.10 margaritas", day: ["Tuesday"]),
        BarEvent(title: "Open Mic", location: "710", timeDescription: "6:30pm", description: "2 for 1 whiskey shots", day: ["Wednesday"]),
        BarEvent(title: "Karaoke", location: "710", timeDescription: "8pm", description: "$7.10 bottle and drafts until 8pm", day: ["Thursday"]),
        BarEvent(title: "Karaoke", location: "710", timeDescription: "8pm", description: "All drinks $7.10 5-8pm", day: ["Friday"]),
        BarEvent(title: "Trivia", location: "Duck Dive", timeDescription: "8pm", description: "", day: ["Wednesday"]),
        BarEvent(title: "Industry Night (Hospitality)", location: "PB Avenue", timeDescription: "8pm", description: "Free Entry for Industry Workers, 1/2 Off VIP Tables & Bottle service for Industry Workers, 1/2 Off drinks for Industry Workers", day: ["Sunday"]),
        BarEvent(title: "College Night", location: "PB Avenue", timeDescription: "", description: "Free entry, $5 white claws, $6 green tea shots", day: ["Thursday"]),
        BarEvent(title: "No Introduction", location: "PB Avenue", timeDescription: "", description: "$5 white claws", day: ["Friday"]),
        BarEvent(title: "Takeover", location: "PB Avenue", timeDescription: "", description: "$5 white claws", day: ["Saturday"])
]

let sampleDeals: [BarDeal] = [
    BarDeal(title: "Happy Hour", location: "Hideaway", timeDescription: "3pm - 6:30pm", description: "+$1 to make any cocktail double shot + double sized, +$1 to size up any beer to 32oz, ½ off shots & bottles/cans of beer", day: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]),
    BarDeal(title: "Sunday Swim Club", location: "Firehouse", timeDescription: "", description: "$18 Bottle of Bubbles, $10 frozen drinks", day: ["Sunday"]),
        BarDeal(title: "Sunday Swim Club", location: "Firehouse", timeDescription: "", description: "$18 Bottle of Bubbles, $10 frozen drinks", day: ["Sunday"]),
        BarDeal(title: "Taco Tuesday", location: "Firehouse", timeDescription: "", description: "$5 Pacificos, $10 Margaritas", day: ["Tuesday"]),
        BarDeal(title: "Wine Wednesday", location: "Firehouse", timeDescription: "", description: "½ off bottle wine and charcuterie", day: ["Wednesday"]),
        BarDeal(title: "College Thursday", location: "Firehouse", timeDescription: "", description: "$5 Drafts, $7 Wells", day: ["Thursday"]),
        BarDeal(title: "Bottomless Mimosas", location: "Firehouse", timeDescription: "10am - 1pm", description: "", day: ["Saturday"]),
        BarDeal(title: "Happy Hour", location: "PB Local", timeDescription: "4pm - 7pm", description: "$8 Cocktails, $5 High Noons", day: ["Wednesday", "Thursday", "Friday"]),
        BarDeal(title: "House Thursdays", location: "PB Local", timeDescription: "9pm - 2am", description: "50% off wells, bottles, & cans", day: ["Thursday"]),
        BarDeal(title: "$5 Mini Pitchers", location: "Open Bar", timeDescription: "", description: "$5 mini pitcher", day: ["Monday", "Tuesday", "Wednesday", "Thursday"]),
        BarDeal(title: "Happy Hour", location: "The Beverly", timeDescription: "4pm - 5pm", description: "1/2 off specialty cocktails", day: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]),
        BarDeal(title: "Happy Hour", location: "Flamingo Deck", timeDescription: "4pm - 7pm", description: "$8 select cocktails and wine, $5 select drafts", day: ["Monday", "Tuesday", "Wednesday", "Friday"]),
        BarDeal(title: "Thursday Happy Hour", location: "Flamingo Deck", timeDescription: "4pm - 7pm", description: "$8 select cocktails and wine, $5 select drafts + $10 OFF Punch Bowls", day: ["Thursday"]),
        BarDeal(title: "Bottomless Mimosas", location: "Flamingo Deck", timeDescription: "10am - 2pm", description: "$15 Bottomless Mimosas", day: ["Sunday"]),
        BarDeal(title: "Happy Hour", location: "Mavericks", timeDescription: "2pm - 6pm", description: "$4 beers wines and wells, $6 margs/mai tais", day: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]),
        BarDeal(title: "Taco Tuesday", location: "Mavericks", timeDescription: "", description: "$3 tequila/mexican beers, $3.50 margs, $2.5, $3.5, $4.5 tacos", day: ["Tuesday"]),
        BarDeal(title: "Happy Hour", location: "Alehouse", timeDescription: "2pm - 5pm", description: "½ off bottles of wine + craft cocktails, $5 draft beer, well cocktails $5", day: ["Monday", "Tuesday", "Thursday", "Friday"]),
        BarDeal(title: "Wednesday Happy Hour", location: "Alehouse", timeDescription: "2pm - 5pm", description: "½ off bottles of wine + craft cocktails, $5 draft beer, well cocktails $5 + ½ off wine bottles all day", day: ["Wednesday"]),
        BarDeal(title: "Happy Hour", location: "Moonshine", timeDescription: "4pm - 7pm", description: "$5 wells, domestics, and moonshine, 2 for 1 buena cerveza", day: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]),
        BarDeal(title: "Taco Tuesday", location: "Duck Dive", timeDescription: "6pm - Close", description: "$8 margs, $7 tequila shots, $6 pacifico beers", day: ["Tuesday"]),
        BarDeal(title: "Wine Wednesday", location: "Duck Dive", timeDescription: "6pm - 10pm", description: "½ off bottles & martini specials", day: ["Wednesday"]),
        BarDeal(title: "Old Fashioned Thursday", location: "Duck Dive", timeDescription: "6pm - Close", description: "$10 build-your-own-old fashioned", day: ["Thursday"]),
        BarDeal(title: "Happy Hour", location: "Duck Dive", timeDescription: "3pm - 6pm", description: "$8 select cocktails, 4 select wines & drafts, ½ off select snacks and shares", day: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]),
        BarDeal(title: "All Day Specials", location: "Dirty Birds", timeDescription: "", description: "$5 mimosas, $15 champagne bottles, $30 buckets domestic beers (bottles) and white claw cans, $35 buckets high noon", day: ["Sunday", "Saturday"]),
        BarDeal(title: "Happy Hour", location: "Dirty Birds", timeDescription: "3pm - 6pm", description: "½ off select beer pitchers, $6 coors banquet beer", day: ["Monday", "Wednesday", "Friday"]),
        BarDeal(title: "All Day Happy Hour", location: "Dirty Birds", timeDescription: "", description: "½ off select beer pitchers, $6 coors banquet beer", day: ["Tuesday"]),
        BarDeal(title: "Thursday Happy Hour", location: "Dirty Birds", timeDescription: "3pm - 6pm", description: "½ off select beer pitchers, $6 coors banquet beer + $7 assorted Cutwater cans", day: ["Thursday"]),
        BarDeal(title: "Happy Hour", location: "Bar Ella", timeDescription: "4pm - 6pm", description: "$4 buds and michelob ultra, $5 wells, select lagers, coors, white claws, and high noons, $6 classic cocktails, drafts, cider, and select wine by the glass", day: ["Monday", "Tuesday", "Wednesday", "Thursday"]),
        BarDeal(title: "Happy Hour", location: "Bar Ella", timeDescription: "4pm - 7pm", description: "$4 buds and michelob ultra, $5 wells, select lagers, coors, white claws, and high noons, $6 classic cocktails, drafts, cider, and select wine by the glass", day: ["Friday"]),
        BarDeal(title: "Wine Special", location: "Bar Ella", timeDescription: "", description: "1/2 Off Wine Bottles, $5 Glasses", day: ["Monday"]),
        BarDeal(title: "Cocktail Special", location: "Bar Ella", timeDescription: "", description: "½ off specialty cocktails", day: ["Tuesday"]),
        BarDeal(title: "Martini Special", location: "Bar Ella", timeDescription: "", description: "$8 Martinis", day: ["Wednesday"]),
        BarDeal(title: "Bottomless Mimosas", location: "Bar Ella", timeDescription: "11am - 2pm", description: "$16 Bottomless Mimosas", day: ["Sunday", "Saturday"])
]

// MARK: - View
struct DealsAndEventsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var serverDate: Date = Date()

    // Fetch server date via HTTP "Date" header
    private func fetchServerDate() {
        guard let url = URL(string: "https://your-api-host.com/events/") else { return }
        URLSession.shared.dataTask(with: url) { _, response, _ in
            guard let httpRes = response as? HTTPURLResponse,
                  let dateHeader = httpRes.value(forHTTPHeaderField: "Date") else {
                return
            }
            // Parse "Date" header directly
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
            if let date = formatter.date(from: dateHeader) {
                DispatchQueue.main.async { self.serverDate = date }
            }
        }.resume()
    }

    // Compute weekday from serverDate
    private var todayName: String {
        let df = DateFormatter()
        df.locale = Locale.current
        df.dateFormat = "EEEE"
        return df.string(from: serverDate)
    }

    private var filteredEvents: [BarEvent] {
        sampleEvents.filter { event in
            event.day.contains(todayName) && event.matchesSearch(query: searchText)
        }
    }

    private var filteredDeals: [BarDeal] {
        sampleDeals.filter { deal in
            deal.day.contains(todayName) && deal.matchesSearch(query: searchText)
        }
    }

    var body: some View {
        ZStack {
            Color("DarkBlue").ignoresSafeArea()

            VStack(spacing: 0) {
                // Search Bar
                TextField("Search deals and events", text: $searchText)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top)
                    .foregroundColor(.white)

                ScrollView {
                    VStack(spacing: 30) {
                        if !filteredEvents.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Today's Events")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                ForEach(filteredEvents) { event in
                                    DetailedEventCard(
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
                                    DetailedEventCard(
                                        title: deal.title,
                                        location: deal.location,
                                        time: deal.timeDescription,
                                        description: deal.description
                                    )
                                }
                            }
                        }

                        if filteredEvents.isEmpty && filteredDeals.isEmpty {
                            Text("No deals or events available for \(todayName).")
                                .foregroundColor(.white.opacity(0.7))
                                .padding()
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Map")
                    }
                    .foregroundColor(Color("Salmon"))
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Deals & Events")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .onAppear { fetchServerDate() }
    }
}

#Preview("Deals and Events") {
    NavigationStack { DealsAndEventsView() }
}
