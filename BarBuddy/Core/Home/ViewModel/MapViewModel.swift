//
//  MapViewModel.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/5/25.
//

import Foundation
import SwiftUI
@preconcurrency import _MapKit_SwiftUI

@MainActor
@Observable
final class MapViewModel {
    var cameraPosition: MapCameraPosition = .userLocation(
        fallback: .automatic
    )
    var statuses: [BarStatus] = []
    var pricing: [Int: String] = [:]

    // MARK: – Static list of bars
    /// Type Bars is a typealias of [Bar]
    var bars: Bars = [
        Bar(id: 0,
            name: "Mavericks Beach Club",
            address: "860 Garnet Ave, San Diego, CA 92109",
            latitude: 32.7969526,
            longitude: -117.2543182,
            images: []
           ),
        Bar(
            id: 1,
            name: "Thrusters Lounge",
            address: "4633 Mission Blvd, San Diego, CA 92109",
            latitude: 32.7982187,
            longitude: -117.2558549,
            images: []
        ),
        Bar(
            id: 2,
            name: "710 Beach Club",
            address: "710 Garnet Ave, San Diego, CA 92109",
            latitude: 32.7964687,
            longitude: -117.2565146,
            images: []
        ),
        Bar(
            id: 3,
            name: "Open Bar",
            address: "4302 Mission Blvd, San Diego, CA 92109",
            latitude: 32.7937602,
            longitude: -117.2547777,
            images: []
        ),
        Bar(
            id: 4,
            name: "The Grass Skirt",
            address: "910 Grand Ave, San Diego, CA 92109",
            latitude: 32.7955066,
            longitude: -117.2528919,
            images: []
        ),
        Bar(
            id: 5,
            name: "Hideaway",
            address: "4474 Mission Blvd, San Diego, CA 92109",
            latitude: 32.7961859,
            longitude: -117.2558475,
            images: []
        ),
        Bar(
            id: 6,
            name: "Flamingo Deck",
            address: "4609 Mission Blvd, San Diego, CA 92109",
            latitude: 32.7911123,
            longitude: -117.2540975,
            images: []
        ),
        Bar(
            id: 7,
            name: "The Beverly Beach Garden",
            address: "4190 Mission Blvd, San Diego, CA 92109",
            latitude: 32.7924436,
            longitude: -117.2544375,
            images: []
        ),
        Bar(
            id: 8,
            name: "Riptides PB",
            address: "1014 Grand Ave, San Diego, CA 92109",
            latitude: 32.7959306,
            longitude: -117.2510682,
            images: []
        ),
        Bar(
            id: 9,
            name: "PB Avenue",
            address: "1060 Garnet Ave, San Diego, CA 92109",
            latitude: 32.7977653,
            longitude: -117.2506176,
            images: []
        ),

        Bar(
            id: 10,
            name: "Moonshine Beach",
            address: "1165 Garnet Ave, San Diego, CA 92109",
            latitude: 32.7980179,
            longitude: -117.2484153,
            location: "",
            usersAtBar: 0,
            currentStatus: "",
            averageRating: "",
            images: [],
            currentUserCount: "",
            activityLevel: ""
        ),
        Bar(
            id: 11,
            name: "PB Shore Club",
            address: "4343 Ocean Blvd, San Diego, CA 92109",
            latitude: 32.7942403,
            longitude: -117.2558471,
            location: "",
            usersAtBar: 0,
            currentStatus: "",
            averageRating: "",
            images: [],
            currentUserCount: "",
            activityLevel: ""
        ),
        Bar(
            id: 12,
            name: "Society PB",
            address: "1051 Garnet Ave, San Diego, CA 92109",
            latitude: 32.7975231,
            longitude: -117.2506688,
            location: "",
            usersAtBar: 0,
            currentStatus: "",
            averageRating: "",
            images: [],
            currentUserCount: "",
            activityLevel: ""
        ),
        Bar(
            id: 13,
            name: "Lahaina Beach House",
            address: "710 Oliver Ct, San Diego, CA 92109",
            latitude: 32.7916952,
            longitude: -117.2551161,
            location: "",
            usersAtBar: 0,
            currentStatus: "",
            averageRating: "",
            images: [],
            currentUserCount: "",
            activityLevel: ""
        ),
        Bar(
            id: 14,
            name: "Break Point",
            address: "945 Garnet Ave, San Diego, CA 92109",
            latitude: 32.7970878,
            longitude: -117.2526739,
            location: "",
            usersAtBar: 0,
            currentStatus: "",
            averageRating: "",
            images: [],
            currentUserCount: "",
            activityLevel: ""
        ),
        Bar(
            id: 15,
            name: "Dirty Birds",
            address: "4656 Mission Blvd, San Diego, CA 92109",
            latitude: 32.7987627,
            longitude: -117.2563120,
            location: "",
            usersAtBar: 0,
            currentStatus: "",
            averageRating: "",
            images: [],
            currentUserCount: "",
            activityLevel: ""
        ),
        Bar(
            id: 16,
            name: "bar Ella",
            address: "915 Garnet Ave, San Diego, CA 92109",
            latitude: 32.7976868,
            longitude: -117.2512401,
            location: "",
            usersAtBar: 0,
            currentStatus: "",
            averageRating: "",
            images: [],
            currentUserCount: "",
            activityLevel: ""
        ),
        Bar(
            id: 17,
            name: "Alehouse",
            address: "721 Grand Ave, San Diego, CA 92109",
            latitude: 32.7943251,
            longitude: -117.2552584,
            location: "",
            usersAtBar: 0,
            currentStatus: "",
            averageRating: "",
            images: [],
            currentUserCount: "",
            activityLevel: ""
        ),
        Bar(
            id: 18,
            name: "The Duck Dive",
            address: "4650 Mission Blvd, San Diego, CA 92109",
            latitude: 32.7985307,
            longitude: -117.2562483,
            location: "",
            usersAtBar: 0,
            currentStatus: "",
            averageRating: "",
            images: [],
            currentUserCount: "",
            activityLevel: ""
        ),
        Bar(
            id: 19,
            name: "PB Local",
            address: "809 Thomas Ave, San Diego, CA 92109",
            latitude: 32.7936288,
            longitude: -117.2541387,
            location: "",
            usersAtBar: 0,
            currentStatus: "",
            averageRating: "",
            images: [],
            currentUserCount: "",
            activityLevel: ""
        ),
        Bar(
            id: 20,
            name: "Firehouse",
            address: "722 Grand Ave, San Diego, CA 92109",
            latitude: 32.7947949,
            longitude: -117.2555755,
            location: "",
            usersAtBar: 0,
            currentStatus: "",
            averageRating: "",
            images: [],
            currentUserCount: "",
            activityLevel: ""
        ),
        Bar(
            id: 21,
            name: "Waterbar",
            address: "4325 Ocean Blvd, San Diego, CA 92109",
            latitude: 32.79393763764441,
            longitude: -117.25568880504693,
            location: "",
            usersAtBar: 0,
            currentStatus: "",
            averageRating: "",
            images: [],
            currentUserCount: "",
            activityLevel: ""
        ),
        Bar(
            id: 22,
            name: "Tap Room",
            address: "1269 Garnet Ave, San Diego, CA 92109",
            latitude: 32.79830577170787,
            longitude: -117.24664621336298,
            location: "",
            usersAtBar: 0,
            currentStatus: "",
            averageRating: "",
            images: [],
            currentUserCount: "",
            activityLevel: ""
        ),
        Bar(
            id: 23,
            name: "The Collective",
            address: "1220 Garnet Ave, San Diego, CA 92109",
            latitude: 32.7983731693196,
            longitude: -117.24682047353912,
            location: "",
            usersAtBar: 0,
            currentStatus: "",
            averageRating: "",
            images: [],
            currentUserCount: "",
            activityLevel: ""
        ),
        Bar(
            id: 24,
            name: "Baja Beach Cafe",
            address: "701 Thomas Ave, San Diego, CA 92109",
            latitude: 32.793322191294415,
            longitude: -117.25567834010458,
            location: "",
            usersAtBar: 0,
            currentStatus: "",
            averageRating: "",
            images: [],
            currentUserCount: "",
            activityLevel: ""
        ),
        Bar(
            id: 25,
            name: "Bare Back Grill",
            address: "4640 Mission Blvd, San Diego, CA 92109",
            latitude: 32.798274966357184,
            longitude: -117.25623510971276,
            location: "",
            usersAtBar: 0,
            currentStatus: "",
            averageRating: "",
            images: [],
            currentUserCount: "",
            activityLevel: ""
        )
    ]

    private let BAR_HOURS: [String : [String : String]] = [
        "Mavericks Beach Club": [
            "Monday":    "4 PM – 2 AM",
            "Tuesday":   "12 PM – 2 AM",
            "Wednesday": "12 PM – 2 AM",
            "Thursday":  "12 PM – 2 AM",
            "Friday":    "12 PM – 2 AM",
            "Saturday":  "10 AM – 2 AM",
            "Sunday":    "10 AM – 12 AM"
        ],
        "Thrusters Lounge": [
            "Monday":    "5 PM – 2 AM",
            "Tuesday":   "5 PM – 2 AM",
            "Wednesday": "5 PM – 2 AM",
            "Thursday":  "5 PM – 2 AM",
            "Friday":    "3 PM – 2 AM",
            "Saturday":  "3 PM – 2 AM",
            "Sunday":    "3 PM – 2 AM"
        ],
        "710 Beach Club": [
            "Monday":    "11:30 AM – 2 AM",
            "Tuesday":   "11:30 AM – 2 AM",
            "Wednesday": "11:30 AM – 2 AM",
            "Thursday":  "11:30 AM – 2 AM",
            "Friday":    "11:30 AM – 2 AM",
            "Saturday":  "10 AM – 2 AM",
            "Sunday":    "10 AM – 2 AM"
        ],
        "Open Bar": [
            "Monday":    "8 AM – 2 AM",
            "Tuesday":   "8 AM – 2 AM",
            "Wednesday": "8 AM – 2 AM",
            "Thursday":  "8 AM – 2 AM",
            "Friday":    "8 AM – 2 AM",
            "Saturday":  "8 AM – 2 AM",
            "Sunday":    "8 AM – 2 AM"
        ],
        "The Grass Skirt": [
            "Monday":    "5 PM – 11 PM",
            "Tuesday":   "5 PM – 11 PM",
            "Wednesday": "5 PM – 11 PM",
            "Thursday":  "5 PM – 12 AM",
            "Friday":    "5 PM – 2 AM",
            "Saturday":  "5 PM – 2 AM",
            "Sunday":    "5 PM – 12 AM"
        ],
        "Hideaway": [
            "Monday":    "11 AM – 2 AM",
            "Tuesday":   "11 AM – 2 AM",
            "Wednesday": "11 AM – 2 AM",
            "Thursday":  "11 AM – 2 AM",
            "Friday":    "11 AM – 2 AM",
            "Saturday":  "9 AM – 2 AM",
            "Sunday":    "9 AM – 2 AM"
        ],
        "Flamingo Deck": [
            "Monday":    "12 PM – 12 AM",
            "Tuesday":   "12 PM – 12 AM",
            "Wednesday": "12 PM – 12 AM",
            "Thursday":  "12 PM – 12 AM",
            "Friday":    "12 PM – 2 AM",
            "Saturday":  "10 AM – 2 AM",
            "Sunday":    "10 AM – 12 AM"
        ],
        "The Beverly Beach Garden": [
            "Monday":    "12 PM – 2 AM",
            "Tuesday":   "12 PM – 2 AM",
            "Wednesday": "12 PM – 2 AM",
            "Thursday":  "12 PM – 2 AM",
            "Friday":    "12 PM – 2 AM",
            "Saturday":  "12 PM – 2 AM",
            "Sunday":    "12 PM – 2 AM"
        ],
        "Riptides PB": [
            "Monday":    "12 PM – 2 AM",
            "Tuesday":   "12 PM – 2 AM",
            "Wednesday": "12 PM – 2 AM",
            "Thursday":  "12 PM – 2 AM",
            "Friday":    "12 PM – 2 AM",
            "Saturday":  "11 AM – 2 AM",
            "Sunday":    "11 AM – 2 AM"
        ],
        "PB Avenue": [
            "Monday":    "Closed",
            "Tuesday":   "Closed",
            "Wednesday": "Closed",
            "Thursday":  "9 PM – 2 AM",
            "Friday":    "9 PM – 2 AM",
            "Saturday":  "9 PM – 2 AM",
            "Sunday":    "10 PM – 2 AM"
        ],
        "Moonshine Beach": [
            "Monday":    "Closed",
            "Tuesday":   "5 PM – 1 AM",
            "Wednesday": "Closed",
            "Thursday":  "Closed",
            "Friday":    "5 PM – 2 AM",
            "Saturday":  "5 PM – 2 AM",
            "Sunday":    "4 PM – 2 AM"
        ],
        "PB Shore Club": [
            "Monday":    "10 AM – 2 AM",
            "Tuesday":   "10 AM – 2 AM",
            "Wednesday": "10 AM – 2 AM",
            "Thursday":  "10 AM – 2 AM",
            "Friday":    "10 AM – 2 AM",
            "Saturday":  "9 AM – 2 AM",
            "Sunday":    "9 AM – 12 AM"
        ],
        "Society PB": [
            "Monday":    "4 PM – 2 AM",
            "Tuesday":   "4 PM – 2 AM",
            "Wednesday": "4 PM – 2 AM",
            "Thursday":  "4 PM – 2 AM",
            "Friday":    "4 PM – 2 AM",
            "Saturday":  "1 PM – 2 AM",
            "Sunday":    "9:30 AM – 2 AM"
        ],
        "Lahaina Beach House": [
            "Monday":    "9 AM – 9 PM",
            "Tuesday":   "9 AM – 9 PM",
            "Wednesday": "9 AM – 9 PM",
            "Thursday":  "9 AM – 9 PM",
            "Friday":    "9 AM – 9 PM",
            "Saturday":  "9 AM – 9 PM",
            "Sunday":    "9 AM – 9 PM"
        ],
        "Break Point": [
            "Monday":    "Closed",
            "Tuesday":   "Closed",
            "Wednesday": "4 PM – 2 AM",
            "Thursday":  "4 PM – 2 AM",
            "Friday":    "4 PM – 2 AM",
            "Saturday":  "11 AM – 2 AM",
            "Sunday":    "11 AM – 2 AM"
        ],
        "Dirty Birds": [
            "Monday":    "11 AM – 10 PM",
            "Tuesday":   "11 AM – 10 PM",
            "Wednesday": "11 AM – 10 PM",
            "Thursday":  "11 AM – 10 PM",
            "Friday":    "11 AM – 11 PM",
            "Saturday":  "11 AM – 11 PM",
            "Sunday":    "9:30 AM – 9:30 PM"
        ],
        "bar Ella": [
            "Monday":    "4 PM – 12 AM",
            "Tuesday":   "4 PM – 12 AM",
            "Wednesday": "4 PM – 12 AM",
            "Thursday":  "4 PM – 12 AM",
            "Friday":    "4 PM – 2 AM",
            "Saturday":  "11 AM – 2 AM",
            "Sunday":    "9:30 AM – 12 AM"
        ],
        "Alehouse": [
            "Monday":    "11 AM – 2 AM",
            "Tuesday":   "11 AM – 2 AM",
            "Wednesday": "11 AM – 2 AM",
            "Thursday":  "11 AM – 2 AM",
            "Friday":    "11 AM – 2 AM",
            "Saturday":  "10 AM – 2 AM",
            "Sunday":    "10 AM – 2 AM"
        ],
        "The Duck Dive": [
            "Monday":    "10 AM – 11 PM",
            "Tuesday":   "10 AM – 11 PM",
            "Wednesday": "10 AM – 11 PM",
            "Thursday":  "10 AM – 11 PM",
            "Friday":    "10 AM – 12 AM",
            "Saturday":  "9 AM – 12 AM",
            "Sunday":    "9 AM – 11 PM"
        ],
        "PB Local": [
            "Monday":    "Closed",
            "Tuesday":   "Closed",
            "Wednesday": "4 PM – 2 AM",
            "Thursday":  "4 PM – 2 AM",
            "Friday":    "12 PM – 2 AM",
            "Saturday":  "10 AM – 2 AM",
            "Sunday":    "10 AM – 12 AM"
        ],
        "Firehouse": [
            "Monday":    "11 AM – 12 AM",
            "Tuesday":   "11 AM – 12 AM",
            "Wednesday": "11 AM – 12 AM",
            "Thursday":  "11 AM – 2 AM",
            "Friday":    "11 AM – 2 AM",
            "Saturday":  "10 AM – 2 AM",
            "Sunday":    "10 AM – 12 AM"
        ],
        "Waterbar": [
            "Monday":    "11 AM – 12 AM",
            "Tuesday":   "11 AM – 12 AM",
            "Wednesday": "11 AM – 12 AM",
            "Thursday":  "11 AM – 12 AM",
            "Friday":    "11 AM – 2 AM",
            "Saturday":  "10 AM – 2 AM",
            "Sunday":    "10 AM – 12 AM"
        ],
        "Tap Room": [
            "Monday":    "11 AM – 12 AM",
            "Tuesday":   "11 AM – 12 AM",
            "Wednesday": "11 AM – 12 AM",
            "Thursday":  "11 AM – 12 AM",
            "Friday":    "11 AM – 2 AM",
            "Saturday":  "10 AM – 2 AM",
            "Sunday":    "10 AM – 12 AM"
        ],
        "The Collective": [
            "Monday":    "6 PM – 10 PM",
            "Tuesday":   "6 PM – 10 PM",
            "Wednesday": "6 PM – 12 AM",
            "Thursday":  "6 PM – 2 AM",
            "Friday":    "6 PM – 2 AM",
            "Saturday":  "6 PM – 2 AM",
            "Sunday":    "6 AM – 2 AM"
        ],
        "Baja Beach Cafe": [
            "Monday":    "8 AM – 12:30 AM",
            "Tuesday":   "8 AM – 12:30 AM",
            "Wednesday": "8 AM – 12:30 AM",
            "Thursday":  "8 AM – 12:30 AM",
            "Friday":    "8 AM – 2 AM",
            "Saturday":  "8 AM – 2 AM",
            "Sunday":    "8 AM – 12:30 AM"
        ],
        "Bare Back Grill": [
            "Monday":    "10 AM – 10 PM",
            "Tuesday":   "10 AM – 10 PM",
            "Wednesday": "10 AM – 10 PM",
            "Thursday":  "10 AM – 10 PM",
            "Friday":    "10 AM – 11 PM",
            "Saturday":  "10 AM – 11 PM",
            "Sunday":    "10 AM – 10 PM"
        ]
    ]


    private let pacificBeachCoordinate = CLLocationCoordinate2D(
        latitude: 32.794,
        longitude: -117.253
    )

    init() {
        for i in bars.indices {
                bars[i].hours = BAR_HOURS[bars[i].name] ?? [:]
            }
        Task { await loadBarData() }
    }

    func loadBarData() async {
        do {
            self.statuses = try await BarStatusService.shared.fetchStatuses()
//            let summaries = try await BarStatusService.shared
//                .fetchVoteSummaries()

        } catch {
            print("Failed loading bar data:", error)
        }
    }

    func updateCameraPosition(bar: String) async {
        guard let coord = await fetchBarLocation(bar) else { return }
        cameraPosition = .region(
            .init(
                center: coord,
                latitudinalMeters: 300,
                longitudinalMeters: 300
            )
        )
    }

    private func fetchBarLocation(_ bar: String) async
        -> CLLocationCoordinate2D?
    {
        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = bar
        req.region = .init(
            center: pacificBeachCoordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        let result = try? await MKLocalSearch(request: req).start()
        return result?.mapItems.first?.placemark.coordinate
    }
}
