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

/// The MapViewModel class is responsible for managing the map view's state
/// and data. It contains properties for the camera position, bar statuses,
/// pricing, and a static list of bars. The class also includes methods
/// to load bar data and update the camera position based on a selected bar.
final class MapViewModel {
    var cameraPosition: MapCameraPosition = .userLocation(
        fallback: .automatic
    )
    var statuses: [BarStatus] = []

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

    private let pacificBeachCoordinate = CLLocationCoordinate2D(
        latitude: 32.794,
        longitude: -117.253
    )

    init() {
        Task { await loadBarData() }
    }

    func loadBarData() async {
        async let statusJob = BarNetworkManager.shared.fetchStatuses()

        do {
            self.statuses = try await statusJob
        } catch {
            print("Could not load statuses: \(error)")
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
