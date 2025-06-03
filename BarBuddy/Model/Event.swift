//
//  BarEvent.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/1/25.
//

import Foundation

// MARK: - Models
struct Event: Identifiable, Searchable, Codable {
    let id: Int
    let bar: Int
    let eventName: String
    let eventTime: Date
    let eventDescription: String
    let isToday: String
    let barName: String
    
    func matchesSearch(query: String) -> Bool {
        query.isEmpty || eventName.localizedCaseInsensitiveContains(query)
        || barName.localizedCaseInsensitiveContains(query)
        || eventDescription.localizedCaseInsensitiveContains(query)
    }
    
    var formattedTime: String {
        return eventTime.formatted(.dateTime.hour().minute())
    }
}

// This is just a temporary struct to represent bar events. Will not be used in production.
struct BarEvent: Identifiable, Searchable {
    let id = UUID()
    let title: String
    let location: String
    let timeDescription: String
    let description: String
    let day: [String]

    func matchesSearch(query: String) -> Bool {
        query.isEmpty || title.localizedCaseInsensitiveContains(query)
            || location.localizedCaseInsensitiveContains(query)
            || description.localizedCaseInsensitiveContains(query)
    }
}
extension BarEvent {
    // MARK: - Sample Data
    static let allEvents: [BarEvent] = [
        BarEvent(
            title: "College Night",
            location: "Hideaway",
            timeDescription: "9pm - Close",
            description: "2 for $9 Cocktails, $2.25 Red Bull w/ Cocktail",
            day: ["Thursday"]
        ),
        BarEvent(
            title: "College Night",
            location: "PB Shoreclub",
            timeDescription: "8pm - Close",
            description: "$5 Wells and Slushies",
            day: ["Thursday"]
        ),
        BarEvent(
            title: "College Night",
            location: "Hideaway",
            timeDescription: "9pm - Close",
            description: "2 for $9 Cocktails, $2.25 Red Bull w/ Cocktail",
            day: ["Thursday"]
        ),
        BarEvent(
            title: "College Night",
            location: "PB Shoreclub",
            timeDescription: "8pm - Close",
            description: "$5 Wells and Slushies",
            day: ["Thursday"]
        ),
        BarEvent(
            title: "Trivia Night",
            location: "PB Shoreclub",
            timeDescription: "7pm - 10pm",
            description: "1/2 Off Select Drafts, $7 Wine, $6 Ketel One/Crown Royal",
            day: ["Tuesday"]
        ),
        BarEvent(
            title: "Industry Monday",
            location: "PB Shoreclub",
            timeDescription: "8pm - Close",
            description:
                "$6 Herradura, Tits & High Noon, 52% OFF Industry Drink Tabs",
            day: ["Monday"]
        ),
        BarEvent(
            title: "Fish Races",
            location: "PB Shoreclub",
            timeDescription: "8pm - Close",
            description: "$6 absolut/altos/jameson/kona drafts",
            day: ["Wednesday"]
        ),
        BarEvent(
            title: "Live DJs",
            location: "Firehouse",
            timeDescription: "12pm - Close",
            description: "",
            day: ["Sunday", "Saturday"]
        ),
        BarEvent(
            title: "Live Music",
            location: "Firehouse",
            timeDescription: "6pm",
            description: "",
            day: ["Wednesday"]
        ),
        BarEvent(
            title: "Live DJs",
            location: "Firehouse",
            timeDescription: "9pm - Close",
            description: "",
            day: ["Thursday"]
        ),
        BarEvent(
            title: "Solset DJs",
            location: "Firehouse",
            timeDescription: "5pm - Close",
            description: "",
            day: ["Friday"]
        ),
        BarEvent(
            title: "Karaoke",
            location: "PB Local",
            timeDescription: "9pm - 2am",
            description: "$8 Espresso Martinis, $5 Wells, Bottles, Cans",
            day: ["Wednesday"]
        ),
        BarEvent(
            title: "Trivia",
            location: "PB Local",
            timeDescription: "7pm - 9pm",
            description:
                "$6 Wells & Drafts, $8 Select Apps, Prizes for 1st, 2nd & 3rd places",
            day: ["Thursday"]
        ),
        BarEvent(
            title: "Industry Tuesday",
            location: "Flamingo Deck",
            timeDescription: "",
            description: "50% off drinks for industry workers",
            day: ["Tuesday"]
        ),
        BarEvent(
            title: "Trivia",
            location: "Mavericks",
            timeDescription: "7pm - 9pm",
            description: "$4 select beers, hard teas, and shots",
            day: ["Wednesday"]
        ),
        BarEvent(
            title: "Karaoke",
            location: "710",
            timeDescription: "8pm",
            description:
                "Mimosa flight $25, frozen slushie flight $16, colossal bloody mary $19 ALL UNTIL 2pm",
            day: ["Sunday"]
        ),
        BarEvent(
            title: "Live Band",
            location: "710",
            timeDescription: "9pm",
            description:
                "Mimosa flight $25, frozen slushie flight $16, colossal bloody mary $19 ALL UNTIL 2pm",
            day: ["Saturday"]
        ),
        BarEvent(
            title: "Beer Pong",
            location: "710",
            timeDescription: "",
            description: "$7.10 ALL drinks",
            day: ["Monday"]
        ),
        BarEvent(
            title: "Trivia",
            location: "710",
            timeDescription: "7pm",
            description: "2 for 1 tequila shots, $7.10 margaritas",
            day: ["Tuesday"]
        ),
        BarEvent(
            title: "Open Mic",
            location: "710",
            timeDescription: "6:30pm",
            description: "2 for 1 whiskey shots",
            day: ["Wednesday"]
        ),
        BarEvent(
            title: "Karaoke",
            location: "710",
            timeDescription: "8pm",
            description: "$7.10 bottle and drafts until 8pm",
            day: ["Thursday"]
        ),
        BarEvent(
            title: "Karaoke",
            location: "710",
            timeDescription: "8pm",
            description: "All drinks $7.10 5-8pm",
            day: ["Friday"]
        ),
        BarEvent(
            title: "Trivia",
            location: "Duck Dive",
            timeDescription: "8pm",
            description: "",
            day: ["Wednesday"]
        ),
        BarEvent(
            title: "Industry Night (Hospitality)",
            location: "PB Avenue",
            timeDescription: "8pm",
            description:
                "Free Entry for Industry Workers, 1/2 Off VIP Tables & Bottle service for Industry Workers, 1/2 Off drinks for Industry Workers",
            day: ["Sunday"]
        ),
        BarEvent(
            title: "College Night",
            location: "PB Avenue",
            timeDescription: "",
            description: "Free entry, $5 white claws, $6 green tea shots",
            day: ["Thursday"]
        ),
        BarEvent(
            title: "No Introduction",
            location: "PB Avenue",
            timeDescription: "",
            description: "$5 white claws",
            day: ["Friday"]
        ),
        BarEvent(
            title: "Takeover",
            location: "PB Avenue",
            timeDescription: "",
            description: "$5 white claws",
            day: ["Saturday"]
        ),
    ]
}
