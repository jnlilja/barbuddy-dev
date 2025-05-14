//
//  Event.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/25/25.
//

import Foundation

struct Event: Identifiable, Searchable {
    var id: Int?
    var bar: Int
    var eventName: String
    var eventTime: String
    var isToday: String
    var barName: String

    func matchesSearch(query: String) -> Bool {
        return barName.localizedCaseInsensitiveContains(query)
            || eventName.localizedCaseInsensitiveContains(query)
    }
}
extension Event {
    static let eventData: [Event] = [
        Event(
            bar: 0,
            eventName: "College Night",
            eventTime: "9pm - Close",
            isToday: "",
            barName: "Hideaway"
        ),
        Event(
            bar: 0,
            eventName: "College Night",
            eventTime: "8pm - Close",
            isToday: "",
            barName: "PB Shoreclub"
        ),
        Event(
            bar: 0,
            eventName: "Trivia Night",
            eventTime: "7pm - 10pm",
            isToday: "",
            barName: "PB Shoreclub"
        ),
        Event(
            bar: 0,
            eventName: "Industry Monday",
            eventTime: "8pm - Close",
            isToday: "",
            barName: "PB Shoreclub"
        ),
        Event(
            bar: 0,
            eventName: "Fish Races",
            eventTime: "8pm - Close",
            isToday: "",
            barName: "PB Shoreclub"
        ),
        Event(
            bar: 0,
            eventName: "Live DJs",
            eventTime: "12pm - Close",
            isToday: "",
            barName: "Firehouse"
        ),
        Event(
            bar: 0,
            eventName: "Live Music",
            eventTime: "6pm",
            isToday: "",
            barName: "Firehouse"
        ),
        Event(
            bar: 0,
            eventName: "Live DJs",
            eventTime: "9pm - Close",
            isToday: "",
            barName: "Firehouse"
        ),
        Event(
            bar: 0,
            eventName: "Solset DJs",
            eventTime: "5pm - Close",
            isToday: "",
            barName: "Firehouse"
        ),
        Event(
            bar: 0,
            eventName: "Karaoke",
            eventTime: "9pm - 2am",
            isToday: "",
            barName: "PB Local"
        ),
        Event(
            bar: 0,
            eventName: "Trivia",
            eventTime: "7pm - 9pm",
            isToday: "",
            barName: "PB Local"
        ),
        Event(
            bar: 0,
            eventName: "Industry Tuesday",
            eventTime: "",
            isToday: "",
            barName: "Flamingo Deck"
        ),
        Event(
            bar: 0,
            eventName: "Trivia",
            eventTime: "7pm - 9pm",
            isToday: "",
            barName: "Mavericks"
        ),
        Event(
            bar: 0,
            eventName: "Karaoke",
            eventTime: "8pm",
            isToday: "",
            barName: "710"
        ),
        Event(
            bar: 0,
            eventName: "Live Band",
            eventTime: "9pm",
            isToday: "",
            barName: "710"
        ),
        Event(
            bar: 0,
            eventName: "Beer Pong",
            eventTime: "",
            isToday: "",
            barName: "710"
        ),
        Event(
            bar: 0,
            eventName: "Trivia",
            eventTime: "7pm",
            isToday: "",
            barName: "710"
        ),
        Event(
            bar: 0,
            eventName: "Open Mic",
            eventTime: "6:30pm",
            isToday: "",
            barName: "710"
        ),
        Event(
            bar: 0,
            eventName: "Karaoke",
            eventTime: "8pm",
            isToday: "",
            barName: "710"
        ),
        Event(
            bar: 0,
            eventName: "Karaoke",
            eventTime: "8pm",
            isToday: "",
            barName: "710"
        ),
        Event(
            bar: 0,
            eventName: "Trivia",
            eventTime: "8pm",
            isToday: "",
            barName: "Duck Dive"
        ),
        Event(
            bar: 0,
            eventName: "Industry Night (Hospitality)",
            eventTime: "8pm",
            isToday: "",
            barName: "PB Avenue"
        ),
        Event(
            bar: 0,
            eventName: "College Night",
            eventTime: "",
            isToday: "",
            barName: "PB Avenue"
        ),
        Event(
            bar: 0,
            eventName: "No Introduction",
            eventTime: "",
            isToday: "",
            barName: "PB Avenue"
        ),
        Event(
            bar: 0,
            eventName: "Takeover",
            eventTime: "",
            isToday: "",
            barName: "PB Avenue"
        ),
        Event(
            bar: 0,
            eventName: "Bowling Special",
            eventTime: "",
            isToday: "",
            barName: "Break Point"
        ),
        Event(
            bar: 0,
            eventName: "Sunset Session (Live Music)",
            eventTime: "6pm - 9pm",
            isToday: "",
            barName: "Waterbar"
        ),
        Event(
            bar: 0,
            eventName: "Trivia",
            eventTime: "7pm",
            isToday: "",
            barName: "Tap Room"
        ),
        Event(
            bar: 0,
            eventName: "Trivia",
            eventTime: "7pm",
            isToday: "",
            barName: "The Collective"
        ),
        Event(
            bar: 0,
            eventName: "Jam Night",
            eventTime: "7pm - 11pm",
            isToday: "",
            barName: "The Collective"
        ),
        Event(
            bar: 0,
            eventName: "Open Mic",
            eventTime: "7:30pm - 12am",
            isToday: "",
            barName: "The Collective"
        ),
    ]
}
