//
//  Event.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/25/25.
//

import Foundation

struct Event: Identifiable, Searchable {
    let id = UUID()
    let title: String
    let location: String
    let timeDescription: String
    let description: String
    let day: [String]
    
    func matchesSearch(query: String) -> Bool {
        return title.lowercased().contains(query.lowercased()) ||
               location.lowercased().contains(query.lowercased()) ||
               timeDescription.lowercased().contains(query.lowercased())
    }
}
extension Event {
    static let eventData: [Event] = [
        Event(
            title: "College Night",
            location: "Hideaway",
            timeDescription: "9pm - Close",
            description: "",
            day: ["Thursday"]
        ),
        Event(
            title: "College Night",
            location: "PB Shoreclub",
            timeDescription: "8pm - Close",
            description: "$5 Wells and Slushies",
            day: ["Thursday"]
        ),
        Event(
            title: "Trivia Night",
            location: "PB Shoreclub",
            timeDescription: "7pm - 10pm",
            description: "1/2 Off Select Drafts, $7 Wine, $6 Ketel One/Crown Royal",
            day: ["Tuesday"]
        ),
        Event(
            title: "Industry Monday",
            location: "PB Shoreclub",
            timeDescription: "8pm - Close",
            description:
                "$6 Herradura, Tits & High Noon, 52% OFF Industry Drink Tabs",
            day: ["Monday"]
        ),
        Event(
            title: "Fish Races",
            location: "PB Shoreclub",
            timeDescription: "8pm - Close",
            description: "$6 absolut/altos/jameson/kona drafts",
            day: ["Wednesday"]
        ),
        Event(
            title: "Live DJs",
            location: "Firehouse",
            timeDescription: "12pm - Close",
            description: "",
            day: ["Sunday, Saturday"]
        ),
        Event(
            title: "Live Music",
            location: "Firehouse",
            timeDescription: "6pm",
            description: "",
            day: ["Wednesday"]
        ),
        Event(
            title: "Live DJs",
            location: "Firehouse",
            timeDescription: "9pm - Close",
            description: "",
            day: ["Thursday"]
        ),
        Event(
            title: "Solset DJs",
            location: "Firehouse",
            timeDescription: "5pm - Close",
            description: "",
            day: ["Friday"]
        ),
        Event(
            title: "Karaoke",
            location: "PB Local",
            timeDescription: "9pm - 2am",
            description: "$8 Espresso Martinis, $5 Wells, Bottles, Cans",
            day: ["Wednesday"]
        ),
        Event(
            title: "Trivia",
            location: "PB Local",
            timeDescription: "7pm - 9pm",
            description:
                "$6 Wells & Drafts, $8 Select Apps, Prizes for 1st, 2nd & 3rd places",
            day: ["Thursday"]
        ),
        Event(
            title: "Industry Tuesday",
            location: "Flamingo Deck",
            timeDescription: "",
            description: "50% off drinks for industry workers",
            day: ["Tuesday"]
        ),
        Event(
            title: "Trivia",
            location: "Mavericks",
            timeDescription: "7pm - 9pm",
            description: "$4 select beers, hard teas, and shots",
            day: ["Wednesday"]
        ),
        Event(
            title: "Karaoke",
            location: "710",
            timeDescription: "8pm",
            description:
                "Mimosa flight $25, frozen slushie flight $16, colossal bloody mary $19 ALL UNTIL 2pm",
            day: ["Sunday"]
        ),
        Event(
            title: "Live Band",
            location: "710",
            timeDescription: "9pm",
            description:
                "Mimosa flight $25, frozen slushie flight $16, colossal bloody mary $19 ALL UNTIL 2pm",
            day: ["Saturday"]
        ),
        Event(
            title: "Beer Pong",
            location: "710",
            timeDescription: "",
            description: "$7.10 ALL drinks",
            day: ["Monday"]
        ),
        Event(
            title: "Trivia",
            location: "710",
            timeDescription: "7pm",
            description: "2 for 1 tequila shots, $7.10 margaritas",
            day: ["Tuesday"]
        ),
        Event(
            title: "Open Mic",
            location: "710",
            timeDescription: "6:30pm",
            description: "2 for 1 whiskey shots",
            day: ["Wednesday"]
        ),
        Event(
            title: "Karaoke",
            location: "710",
            timeDescription: "8pm",
            description: "$7.10 bottle and drafts until 8pm",
            day: ["Thursday"]
        ),
        Event(
            title: "Karaoke",
            location: "710",
            timeDescription: "8pm",
            description: "All drinks $7.10 5-8pm",
            day: ["Friday"]
        ),
        Event(
            title: "Trivia",
            location: "Duck Dive",
            timeDescription: "8pm",
            description: "",
            day: ["Wednesday"]
        ),
        Event(
            title: "Industry Night (Hospitality)",
            location: "PB Avenue",
            timeDescription: "8pm",
            description:
                "Free Entry for Industry Workers, 1/2 Off VIP Tables & Bottle service for Industry Workers, 1/2 Off drinks for Industry Workers",
            day: ["Sunday"]
        ),
        Event(
            title: "College Night",
            location: "PB Avenue",
            timeDescription: "",
            description: "Free entry, $5 white claws, $6 green tea shots",
            day: ["Thursday"]
        ),
        Event(
            title: "No Introduction",
            location: "PB Avenue",
            timeDescription: "",
            description: "$5 white claws",
            day: ["Friday"]
        ),
        Event(
            title: "Takeover",
            location: "PB Avenue",
            timeDescription: "",
            description: "$5 white claws",
            day: ["Saturday"]
        ),
        Event(
            title: "Bowling Special",
            location: "Break Point",
            timeDescription: "",
            description: "Lanes $35 per hour all night",
            day: ["Tuesday, Wednesday, Thursday"]
        ),
        Event(
            title: "Sunset Session (Live Music)",
            location: "Waterbar",
            timeDescription: "6pm - 9pm",
            description: "",
            day: ["Thursday"]
        ),
        Event(
            title: "Trivia",
            location: "Tap Room",
            timeDescription: "7pm",
            description: "",
            day: ["Monday"]
        ),
        Event(
            title: "Trivia",
            location: "The Collective",
            timeDescription: "7pm",
            description: "",
            day: ["Tuesday"]
        ),
        Event(
            title: "Jam Night",
            location: "The Collective",
            timeDescription: "7pm - 11pm",
            description: "All instruments welcome",
            day: ["Wednesday"]
        ),
        Event(
            title: "Open Mic",
            location: "The Collective",
            timeDescription: "7:30pm - 12am",
            description: "Musicians only",
            day: ["Thursday"]
        ),
    ]
}
