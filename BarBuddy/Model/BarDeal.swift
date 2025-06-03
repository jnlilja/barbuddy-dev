//
//  BarDeal.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/1/25.
//
import Foundation

typealias Deals = [BarDeal]

struct BarDeal: Identifiable, Searchable {
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
extension BarDeal {
    static let allDeals: Deals = [
        BarDeal(
            title: "Happy Hour",
            location: "Hideaway",
            timeDescription: "3pm - 6:30pm",
            description:
                "+$1 to make any cocktail double shot + double sized, +$1 to size up any beer to 32oz, ½ off shots & bottles/cans of beer",
            day: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        ),
        BarDeal(
            title: "Sunday Swim Club",
            location: "Firehouse",
            timeDescription: "",
            description: "$18 Bottle of Bubbles, $10 frozen drinks",
            day: ["Sunday"]
        ),
        BarDeal(
            title: "Sunday Swim Club",
            location: "Firehouse",
            timeDescription: "",
            description: "$18 Bottle of Bubbles, $10 frozen drinks",
            day: ["Sunday"]
        ),
        BarDeal(
            title: "Taco Tuesday",
            location: "Firehouse",
            timeDescription: "",
            description: "$5 Pacificos, $10 Margaritas",
            day: ["Tuesday"]
        ),
        BarDeal(
            title: "Wine Wednesday",
            location: "Firehouse",
            timeDescription: "",
            description: "½ off bottle wine and charcuterie",
            day: ["Wednesday"]
        ),
        BarDeal(
            title: "College Thursday",
            location: "Firehouse",
            timeDescription: "",
            description: "$5 Drafts, $7 Wells",
            day: ["Thursday"]
        ),
        BarDeal(
            title: "Bottomless Mimosas",
            location: "Firehouse",
            timeDescription: "10am - 1pm",
            description: "",
            day: ["Saturday"]
        ),
        BarDeal(
            title: "Happy Hour",
            location: "PB Local",
            timeDescription: "4pm - 7pm",
            description: "$8 Cocktails, $5 High Noons",
            day: ["Wednesday", "Thursday", "Friday"]
        ),
        BarDeal(
            title: "House Thursdays",
            location: "PB Local",
            timeDescription: "9pm - 2am",
            description: "50% off wells, bottles, & cans",
            day: ["Thursday"]
        ),
        BarDeal(
            title: "$5 Mini Pitchers",
            location: "Open Bar",
            timeDescription: "",
            description: "$5 mini pitcher",
            day: ["Monday", "Tuesday", "Wednesday", "Thursday"]
        ),
        BarDeal(
            title: "Happy Hour",
            location: "The Beverly",
            timeDescription: "4pm - 5pm",
            description: "1/2 off specialty cocktails",
            day: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        ),
        BarDeal(
            title: "Happy Hour",
            location: "Flamingo Deck",
            timeDescription: "4pm - 7pm",
            description: "$8 select cocktails and wine, $5 select drafts",
            day: ["Monday", "Tuesday", "Wednesday", "Friday"]
        ),
        BarDeal(
            title: "Thursday Happy Hour",
            location: "Flamingo Deck",
            timeDescription: "4pm - 7pm",
            description:
                "$8 select cocktails and wine, $5 select drafts + $10 OFF Punch Bowls",
            day: ["Thursday"]
        ),
        BarDeal(
            title: "Bottomless Mimosas",
            location: "Flamingo Deck",
            timeDescription: "10am - 2pm",
            description: "$15 Bottomless Mimosas",
            day: ["Sunday"]
        ),
        BarDeal(
            title: "Happy Hour",
            location: "Mavericks",
            timeDescription: "2pm - 6pm",
            description: "$4 beers wines and wells, $6 margs/mai tais",
            day: [
                "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday",
                "Saturday",
            ]
        ),
        BarDeal(
            title: "Taco Tuesday",
            location: "Mavericks",
            timeDescription: "",
            description:
                "$3 tequila/mexican beers, $3.50 margs, $2.5, $3.5, $4.5 tacos",
            day: ["Tuesday"]
        ),
        BarDeal(
            title: "Happy Hour",
            location: "Alehouse",
            timeDescription: "2pm - 5pm",
            description:
                "½ off bottles of wine + craft cocktails, $5 draft beer, well cocktails $5",
            day: ["Monday", "Tuesday", "Thursday", "Friday"]
        ),
        BarDeal(
            title: "Wednesday Happy Hour",
            location: "Alehouse",
            timeDescription: "2pm - 5pm",
            description:
                "½ off bottles of wine + craft cocktails, $5 draft beer, well cocktails $5 + ½ off wine bottles all day",
            day: ["Wednesday"]
        ),
        BarDeal(
            title: "Happy Hour",
            location: "Moonshine",
            timeDescription: "4pm - 7pm",
            description:
                "$5 wells, domestics, and moonshine, 2 for 1 buena cerveza",
            day: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        ),
        BarDeal(
            title: "Taco Tuesday",
            location: "Duck Dive",
            timeDescription: "6pm - Close",
            description: "$8 margs, $7 tequila shots, $6 pacifico beers",
            day: ["Tuesday"]
        ),
        BarDeal(
            title: "Wine Wednesday",
            location: "Duck Dive",
            timeDescription: "6pm - 10pm",
            description: "½ off bottles & martini specials",
            day: ["Wednesday"]
        ),
        BarDeal(
            title: "Old Fashioned Thursday",
            location: "Duck Dive",
            timeDescription: "6pm - Close",
            description: "$10 build-your-own-old fashioned",
            day: ["Thursday"]
        ),
        BarDeal(
            title: "Happy Hour",
            location: "Duck Dive",
            timeDescription: "3pm - 6pm",
            description:
                "$8 select cocktails, 4 select wines & drafts, ½ off select snacks and shares",
            day: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        ),
        BarDeal(
            title: "All Day Specials",
            location: "Dirty Birds",
            timeDescription: "",
            description:
                "$5 mimosas, $15 champagne bottles, $30 buckets domestic beers (bottles) and white claw cans, $35 buckets high noon",
            day: ["Sunday", "Saturday"]
        ),
        BarDeal(
            title: "Happy Hour",
            location: "Dirty Birds",
            timeDescription: "3pm - 6pm",
            description: "½ off select beer pitchers, $6 coors banquet beer",
            day: ["Monday", "Wednesday", "Friday"]
        ),
        BarDeal(
            title: "All Day Happy Hour",
            location: "Dirty Birds",
            timeDescription: "",
            description: "½ off select beer pitchers, $6 coors banquet beer",
            day: ["Tuesday"]
        ),
        BarDeal(
            title: "Thursday Happy Hour",
            location: "Dirty Birds",
            timeDescription: "3pm - 6pm",
            description:
                "½ off select beer pitchers, $6 coors banquet beer + $7 assorted Cutwater cans",
            day: ["Thursday"]
        ),
        BarDeal(
            title: "Happy Hour",
            location: "Bar Ella",
            timeDescription: "4pm - 6pm",
            description:
                "$4 buds and michelob ultra, $5 wells, select lagers, coors, white claws, and high noons, $6 classic cocktails, drafts, cider, and select wine by the glass",
            day: ["Monday", "Tuesday", "Wednesday", "Thursday"]
        ),
        BarDeal(
            title: "Happy Hour",
            location: "Bar Ella",
            timeDescription: "4pm - 7pm",
            description:
                "$4 buds and michelob ultra, $5 wells, select lagers, coors, white claws, and high noons, $6 classic cocktails, drafts, cider, and select wine by the glass",
            day: ["Friday"]
        ),
        BarDeal(
            title: "Wine Special",
            location: "Bar Ella",
            timeDescription: "",
            description: "1/2 Off Wine Bottles, $5 Glasses",
            day: ["Monday"]
        ),
        BarDeal(
            title: "Cocktail Special",
            location: "Bar Ella",
            timeDescription: "",
            description: "½ off specialty cocktails",
            day: ["Tuesday"]
        ),
        BarDeal(
            title: "Martini Special",
            location: "Bar Ella",
            timeDescription: "",
            description: "$8 Martinis",
            day: ["Wednesday"]
        ),
        BarDeal(
            title: "Bottomless Mimosas",
            location: "Bar Ella",
            timeDescription: "11am - 2pm",
            description: "$16 Bottomless Mimosas",
            day: ["Sunday", "Saturday"]
        ),
    ]
}
