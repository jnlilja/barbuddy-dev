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
                        }
                        
                        // Deals Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Happy Hours & Deals")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
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

protocol Searchable {
    func matchesSearch(query: String) -> Bool
}

// SAMPLE DATA
let eventData: [Event] = [
    Event(title: "College Night", location: "Hideaway", timeDescription: "9pm - Close", description: "", day: ["Thursday"]),
    Event(title: "College Night", location: "PB Shoreclub", timeDescription: "8pm - Close", description: "$5 Wells and Slushies", day: ["Thursday"]),
    Event(title: "Trivia Night", location: "PB Shoreclub", timeDescription: "7pm - 10pm", description: "1/2 Off Select Drafts, $7 Wine, $6 Ketel One/Crown Royal", day: ["Tuesday"]),
    Event(title: "Industry Monday", location: "PB Shoreclub", timeDescription: "8pm - Close", description: "$6 Herradura, Tits & High Noon, 52% OFF Industry Drink Tabs", day: ["Monday"]),
    Event(title: "Fish Races", location: "PB Shoreclub", timeDescription: "8pm - Close", description: "$6 absolut/altos/jameson/kona drafts", day: ["Wednesday"]),
    Event(title: "Live DJs", location: "Firehouse", timeDescription: "12pm - Close", description: "", day: ["Sunday, Saturday"]),
    Event(title: "Live Music", location: "Firehouse", timeDescription: "6pm", description: "", day: ["Wednesday"]),
    Event(title: "Live DJs", location: "Firehouse", timeDescription: "9pm - Close", description: "", day: ["Thursday"]),
    Event(title: "Solset DJs", location: "Firehouse", timeDescription: "5pm - Close", description: "", day: ["Friday"]),
    Event(title: "Karaoke", location: "PB Local", timeDescription: "9pm - 2am", description: "$8 Espresso Martinis, $5 Wells, Bottles, Cans", day: ["Wednesday"]),
    Event(title: "Trivia", location: "PB Local", timeDescription: "7pm - 9pm", description: "$6 Wells & Drafts, $8 Select Apps, Prizes for 1st, 2nd & 3rd places", day: ["Thursday"]),
    Event(title: "Industry Tuesday", location: "Flamingo Deck", timeDescription: "", description: "50% off drinks for industry workers", day: ["Tuesday"]),
    Event(title: "Trivia", location: "Mavericks", timeDescription: "7pm - 9pm", description: "$4 select beers, hard teas, and shots", day: ["Wednesday"]),
    Event(title: "Karaoke", location: "710", timeDescription: "8pm", description: "Mimosa flight $25, frozen slushie flight $16, colossal bloody mary $19 ALL UNTIL 2pm", day: ["Sunday"]),
    Event(title: "Live Band", location: "710", timeDescription: "9pm", description: "Mimosa flight $25, frozen slushie flight $16, colossal bloody mary $19 ALL UNTIL 2pm", day: ["Saturday"]),
    Event(title: "Beer Pong", location: "710", timeDescription: "", description: "$7.10 ALL drinks", day: ["Monday"]),
    Event(title: "Trivia", location: "710", timeDescription: "7pm", description: "2 for 1 tequila shots, $7.10 margaritas", day: ["Tuesday"]),
    Event(title: "Open Mic", location: "710", timeDescription: "6:30pm", description: "2 for 1 whiskey shots", day: ["Wednesday"]),
    Event(title: "Karaoke", location: "710", timeDescription: "8pm", description: "$7.10 bottle and drafts until 8pm", day: ["Thursday"]),
    Event(title: "Karaoke", location: "710", timeDescription: "8pm", description: "All drinks $7.10 5-8pm", day: ["Friday"]),
    Event(title: "Trivia", location: "Duck Dive", timeDescription: "8pm", description: "", day: ["Wednesday"]),
    Event(title: "Industry Night (Hospitality)", location: "PB Avenue", timeDescription: "8pm", description: "Free Entry for Industry Workers, 1/2 Off VIP Tables & Bottle service for Industry Workers, 1/2 Off drinks for Industry Workers", day: ["Sunday"]),
    Event(title: "College Night", location: "PB Avenue", timeDescription: "", description: "Free entry, $5 white claws, $6 green tea shots", day: ["Thursday"]),
    Event(title: "No Introduction", location: "PB Avenue", timeDescription: "", description: "$5 white claws", day: ["Friday"]),
    Event(title: "Takeover", location: "PB Avenue", timeDescription: "", description: "$5 white claws", day: ["Saturday"]),
    Event(title: "Bowling Special", location: "Break Point", timeDescription: "", description: "Lanes $35 per hour all night", day: ["Tuesday, Wednesday, Thursday"]),
    Event(title: "Sunset Session (Live Music)", location: "Waterbar", timeDescription: "6pm - 9pm", description: "", day: ["Thursday"]),
    Event(title: "Trivia", location: "Tap Room", timeDescription: "7pm", description: "", day: ["Monday"]),
    Event(title: "Trivia", location: "The Collective", timeDescription: "7pm", description: "", day: ["Tuesday"]),
    Event(title: "Jam Night", location: "The Collective", timeDescription: "7pm - 11pm", description: "All instruments welcome", day: ["Wednesday"]),
    Event(title: "Open Mic", location: "The Collective", timeDescription: "7:30pm - 12am", description: "Musicians only", day: ["Thursday"]),
    
    
    
]
let dealData: [Deal] = [
    Deal(title: "Happy Hour", location: "Hideaway", timeDescription: "3pm - 6:30pm", description: "+$1 to make any cocktail double shot + double sized, +$1 to size up any beer to 32oz, ½ off shots & bottles/cans of beer", day: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]),
    Deal(title: "Sunday Swim Club", location: "Firehouse", timeDescription: "", description: "$18 Bottle of Bubbles, $10 frozen drinks", day: ["Sunday"]),
    Deal(title: "Taco Tuesday", location: "Firehouse", timeDescription: "", description: "$5 Pacificos, $10 Margaritas", day: ["Tuesday"]),
    Deal(title: "Wine Wednesday", location: "Firehouse", timeDescription: "", description: "½ off bottle wine and charcuterie", day: ["Wednesday"]),
    Deal(title: "College Thursday", location: "Firehouse", timeDescription: "", description: "$5 Drafts, $7 Wells", day: ["Thursday"]),
    Deal(title: "Bottomless Mimosas", location: "Firehouse", timeDescription: "10am - 1pm", description: "", day: ["Saturday"]),
    Deal(title: "Happy Hour", location: "PB Local", timeDescription: "4pm - 7pm", description: "$8 Cocktails, $5 High Noons", day: ["Wednesday, Thursday, Friday"]),
    Deal(title: "House Thursdays", location: "PB Local", timeDescription: "9pm - 2am", description: "50% off wells, bottles, & cans", day: ["Thursday"]),
    Deal(title: "$5 Mini Pitchers", location: "Open Bar", timeDescription: "", description: "$5 mini pitcher", day: ["Monday, Tuesday, Wednesday, Thursday"]),
    Deal(title: "Happy Hour", location: "The Beverly", timeDescription: "4pm - 5pm", description: "1/2 off specialty cocktails", day: ["Monday, Tuesday, Wednesday, Thursday, Friday"]),
    Deal(title: "Happy Hour", location: "Flamingo Deck", timeDescription: "4pm - 7pm", description: "$8 select cocktails and wine, $5 select drafts", day: ["Monday, Tuesday, Wednesday, Friday"]),
    Deal(title: "Thursday Happy Hour", location: "Flamingo Deck", timeDescription: "4pm - 7pm", description: "$8 select cocktails and wine, $5 select drafts + $10 OFF Punch Bowls", day: ["Thursday"]),
    Deal(title: "Bottomless Mimosas", location: "Flamingo Deck", timeDescription: "10am - 2pm", description: "$15 Bottomless Mimosas", day: ["Sunday"]),//last
    Deal(title: "Happy Hour", location: "Mavericks", timeDescription: "2pm - 6pm", description: "$4 beers wines and wells, $6 margs/mai tais", day: ["Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday"]),
    Deal(title: "Taco Tuesday", location: "Mavericks", timeDescription: "", description: "$3 tequila/mexican beers, $3.50 margs, $2.5, $3.5, $4.5 tacos", day: ["Tuesday"]),
    Deal(title: "Happy Hour", location: "Alehouse", timeDescription: "2pm - 5pm", description: "½ off bottles of wine + craft cocktails, $5 draft beer, well cocktails $5", day: ["Monday, Tuesday, Thursday, Friday"]),
    Deal(title: "Wednesday Happy Hour", location: "Alehouse", timeDescription: "2pm - 5pm", description: "½ off bottles of wine + craft cocktails, $5 draft beer, well cocktails $5 + ½ off wine bottles all day", day: ["Wednesday"]),
    Deal(title: "Happy Hour", location: "Moonshine", timeDescription: "4pm - 7pm", description: "$5 wells, domestics, and moonshine, 2 for 1 buena cerveza", day: ["Monday, Tuesday, Wednesday, Thursday, Friday"]),
    Deal(title: "Taco Tuesday", location: "Duck Dive", timeDescription: "6pm - Close", description: "$8 margs, $7 tequila shots, $6 pacifico beers", day: ["Tuesday"]),
    Deal(title: "Wine Wednesday", location: "Duck Dive", timeDescription: "6pm - 10pm", description: "½ off bottles & martini specials", day: ["Wednesday"]),
    Deal(title: "Old Fashioned Thursday", location: "Duck Dive", timeDescription: "6pm - Close", description: "$10 build-your-own-old fashioned", day: ["Thursday"]),
    Deal(title: "Happy Hour", location: "Duck Dive", timeDescription: "3pm - 6pm", description: "$8 select cocktails, 4 select wines & drafts, ½ off select snacks and shares", day: ["Monday, Tuesday, Wednesday, Thursday, Friday"]),
    Deal(title: "All Day Specials", location: "Dirty Birds", timeDescription: "", description: "$5 mimosas, $15 champagne bottles, $30 buckets domestic beers (bottles) and white claw cans, $35 buckets high noon", day: ["Sunday, Saturday,"]),
    Deal(title: "Happy Hour", location: "Dirty Birds", timeDescription: "3pm - 6pm", description: "½ off select beer pitchers, $6 coors banquet beer", day: ["Monday, Wednesday, Friday"]),
    Deal(title: "All Day Happy Hour", location: "Dirty Birds", timeDescription: "", description: "½ off select beer pitchers, $6 coors banquet beer", day: ["Tuesday"]),
    Deal(title: "Thursday Happy Hour", location: "Dirty Birds", timeDescription: "3pm - 6pm", description: "½ off select beer pitchers, $6 coors banquet beer + $7 assorted Cutwater cans", day: ["Thursday"]),
    Deal(title: "Happy Hour", location: "Bar Ella", timeDescription: "4pm - 6pm", description: "$4 buds and michelob ultra, $5 wells, select lagers, coors, white claws, and high noons, $6 classic cocktails, drafts, cider, and select wine by the glass", day: ["Monday, Tuesday, Wednesday, Thursday"]),
    Deal(title: "Happy Hour", location: "Bar Ella", timeDescription: "4pm - 7pm", description: "$4 buds and michelob ultra, $5 wells, select lagers, coors, white claws, and high noons, $6 classic cocktails, drafts, cider, and select wine by the glass", day: ["Friday"]),
    Deal(title: "Wine Special", location: "Bar Ella", timeDescription: "", description: "1/2 Off Wine Bottles, $5 Glasses", day: ["Monday"]),
    Deal(title: "Cocktail Special", location: "Bar Ella", timeDescription: "", description: "½ off specialty cocktails", day: ["Tuesday"]),
    Deal(title: "Martini Special", location: "Bar Ella", timeDescription: "", description: "$8 Martinis", day: ["Wednesday"]),
    Deal(title: "Bottomless Mimosas", location: "Bar Ella", timeDescription: "11am - 2pm", description: "$16 Bottomless Mimosas", day: ["Sunday, Saturday"]),
    Deal(title: "Happy Hour", location: "The Grass Skirt", timeDescription: "5pm - 6pm", description: "50% off cocktails, tiki shots, punch bowls,  beer and  wine", day: ["Sunday, Monday, Tuesday, Wednesday, Thursday"]),
    Deal(title: "Happy Hour", location: "Break Point", timeDescription: "4pm - 7pm", description: "$2 off drafts, $5 wells and wines, $7 house margaritas, $9 specialty margaritas", day: ["Tuesday, Thursday, Friday"]),
    Deal(title: "Wednesday Happy Hour", location: "Break Point", timeDescription: "4pm - Close", description: "$2 off drafts, $5 wells and wines, $7 house margaritas, $9 specialty margaritas", day: ["Wednesday"]),
    Deal(title: "Happy Hour", location: "Waterbar", timeDescription: "3pm - 5pm", description: "$2 off all drafts, $7 well cocktails, $8 house red/white wines, $10 select cocktails", day: ["Monday, Tuesday, Wednesday, Thursday"]),
    Deal(title: "Wine Wednesday", location: "Waterbar", timeDescription: "", description: "½ off select wines, $2 off all wine by the glass", day: ["Wednesday"]),
    Deal(title: "Bottomless Mimosas", location: "Waterbar", timeDescription: "10am - 2pm", description: "$21 bottomless, must purchase entree with it", day: ["Sunday, Saturday"]),
    Deal(title: "Bottomless Mimosas", location: "Tap Room", timeDescription: "10am - 11am", description: "$10 Bottomless mimosas until 11am, $12 flight of 4 until 1pm", day: ["Sunday, Saturday"]),
    Deal(title: "Happy Hour", location: "Tap Room", timeDescription: "3pm - 6pm", description: "$2 off ALL Taps, Apps, Cocktails, Wines", day: ["Monday, Tuesday, Wednesday, Thursday, Friday"]),
    Deal(title: "Specialty Bottle Day", location: "Tap Room", timeDescription: "", description: "15% off all specialty bottles", day: ["Monday"]),
    Deal(title: "Taps & Wings", location: "Tap Room", timeDescription: "6pm - Close", description: "$5 off select taps and $5 wings", day: ["Tuesday"]),
    Deal(title: "Wine Wednesday", location: "Tap Room", timeDescription: "", description: "½ Off all wine bottles", day: ["Wednesday"]),
    Deal(title: "Happy Hour", location: "The Collective", timeDescription: "6pm - 8pm", description: "$2 off select drinks", day: ["Tuesday, Wednesday, Thursday, Friday, Saturday"]),
    Deal(title: "Happy Hour", location: "Baja Beach Cafe", timeDescription: "4pm - 7pm", description: "All drinks 2 for 1", day: ["Monday, Tuesday, Wednesday, Thursday, Friday"]),
    Deal(title: "Late Night Happy", location: "Baja Beach Cafe", timeDescription: "10:30pm - 12am", description: "All drinks 2 for 1", day: ["Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday"]),
    Deal(title: "Wine Wednesday", location: "Baja Beach Cafe", timeDescription: "", description: "½ off all wine bottles", day: ["Wednesday"]),
    Deal(title: "Happy Hour", location: "Bare Back Grill", timeDescription: "3pm - 6pm", description: "$7 craft beers, $10 craft cocktails", day: ["Monday, Tuesday, Wednesday, Thursday, Friday"]),
    Deal(title: "Slider Night", location: "Bare Back Grill", timeDescription: "", description: "$8 beer flights, $7 sliders", day: ["Thursday"])
    
]
#Preview("Deals and Events") {
    NavigationStack {
        DealsAndEvents()
    }
}
