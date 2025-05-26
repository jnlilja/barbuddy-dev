//
//  MapViewModel.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/5/25.
//

import Foundation
import SwiftUI
import FirebaseAuth

@preconcurrency import _MapKit_SwiftUI

@MainActor
final class MapViewModel: ObservableObject {
    // MARK: – Published properties so SwiftUI updates when they change
    @Published var cameraPosition: MapCameraPosition = .userLocation(
        fallback: .automatic
    )
    @Published var bars: [Bar] = []
    @Published var statuses: [Int: BarStatus] = [:]  // now Equatable
    @Published var music: [Int: String] = [:]
    @Published var pricing: [Int: String] = [:]
    @Published var barVotes: [BarVote] = []
    
    func getBarVotes() async throws -> [BarVote] {
        guard let uid = Auth.auth().currentUser else { throw UsersAPIError.noToken }
        let idToken = try await uid.getIDToken()
        //var request = URLRequest(url: baseURL.appendingPathComponent("users"))
        guard let url = URL(string: "https://barbuddy-backend-148659891217.us-central1.run.app/api/bar-votes/") else {
            return []
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonData = String(data: data, encoding: .utf8) {
                print("bar votes json \(jsonData)")
            }
            return try JSONDecoder().decode([BarVote].self, from: data)
        } catch let e as DecodingError {
            throw UsersAPIError.decoding(e)
        } catch {
            throw UsersAPIError.transport(error)
        }
    }
    
    
    // MARK: – Static list of bars in Pacific Beach
//    let bars: Bars = [
//        Bar(
//            id: 1,
//            name: "Mavericks Beach Club",
//            address: "860 Garnet Ave, San Diego, CA 92109",
//            average_price: "$$",
//            location: Location(
//                latitude: 32.7969526,
//                longitude: -117.2543182
//            ),
//            images: [
//                BarImage(
//                    id: 101,
//                    image: "mavericks_beach_club_1.jpg",
//                    caption: "Outdoor patio with fire pits",
//                    uploaded_at: "2025-01-15T18:30:00Z"
//                ),
//                BarImage(
//                    id: 102,
//                    image: "mavericks_beach_club_2.jpg",
//                    caption: "Tiki bar at night",
//                    uploaded_at: "2025-02-20T21:45:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 2,
//            name: "Thrusters Lounge",
//            address: "4633 Mission Blvd, San Diego, CA 92109",
//            average_price: "$",
//            location: Location(
//                latitude: 32.7982187,
//                longitude: -117.2558549
//            ),
//            images: [
//                BarImage(
//                    id: 201,
//                    image: "thrusters_lounge_1.jpg",
//                    caption: "Main bar area",
//                    uploaded_at: "2024-12-05T22:15:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 3,
//            name: "710 Beach Club",
//            address: "710 Garnet Ave, San Diego, CA 92109",
//            average_price: "$$",
//            location: Location(
//                latitude: 32.7964687,
//                longitude: -117.2565146
//            ),
//            images: [
//                BarImage(
//                    id: 301,
//                    image: "710_beach_club_1.jpg",
//                    caption: "Live music stage",
//                    uploaded_at: "2025-03-10T20:00:00Z"
//                ),
//                BarImage(
//                    id: 302,
//                    image: "710_beach_club_2.jpg",
//                    caption: "Happy hour crowd",
//                    uploaded_at: "2025-03-12T18:30:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 4,
//            name: "Open Bar",
//            address: "4302 Mission Blvd, San Diego, CA 92109",
//            average_price: "$$",
//            location: Location(
//                latitude: 32.7937602,
//                longitude: -117.2547777
//            ),
//            images: [
//                BarImage(
//                    id: 401,
//                    image: "open_bar_1.jpg",
//                    caption: "Rooftop view",
//                    uploaded_at: "2025-01-22T19:45:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 5,
//            name: "The Grass Skirt",
//            address: "910 Grand Ave, San Diego, CA 92109",
//            average_price: "$$$",
//            location: Location(
//                latitude: 32.7955066,
//                longitude: -117.2528919
//            ),
//            images: [
//                BarImage(
//                    id: 501,
//                    image: "grass_skirt_1.jpg",
//                    caption: "Tiki decor entrance",
//                    uploaded_at: "2025-02-14T21:30:00Z"
//                ),
//                BarImage(
//                    id: 502,
//                    image: "grass_skirt_2.jpg",
//                    caption: "Tropical cocktails",
//                    uploaded_at: "2025-02-18T22:15:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 6,
//            name: "Hideaway",
//            address: "4125 Mission Blvd, San Diego, CA 92109",
//            average_price: "$$",
//            location: Location(
//                latitude: 32.7961859,
//                longitude: -117.2558475
//            ),
//            images: [
//                BarImage(
//                    id: 601,
//                    image: "hideaway_1.jpg",
//                    caption: "Cozy interior",
//                    uploaded_at: "2024-11-30T20:45:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 7,
//            name: "Flamingo Deck",
//            address: "3850 Mission Blvd, San Diego, CA 92109",
//            average_price: "$$",
//            location: Location(
//                latitude: 32.7911123,
//                longitude: -117.2540975
//            ),
//            images: [
//                BarImage(
//                    id: 701,
//                    image: "flamingo_deck_1.jpg",
//                    caption: "Sunset view from the deck",
//                    uploaded_at: "2025-04-05T19:30:00Z"
//                ),
//                BarImage(
//                    id: 702,
//                    image: "flamingo_deck_2.jpg",
//                    caption: "Weekend crowd",
//                    uploaded_at: "2025-04-12T21:00:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 8,
//            name: "The Beverly Beach Garden",
//            address: "3954 Mission Blvd, San Diego, CA 92109",
//            average_price: "$$$",
//            location: Location(
//                latitude: 32.7924436,
//                longitude: -117.2544375
//            ),
//            images: [
//                BarImage(
//                    id: 801,
//                    image: "beverly_beach_garden_1.jpg",
//                    caption: "Garden seating area",
//                    uploaded_at: "2025-03-20T17:15:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 9,
//            name: "Riptides Pb",
//            address: "4516 Mission Blvd, San Diego, CA 92109",
//            average_price: "$",
//            location: Location(
//                latitude: 32.7959306,
//                longitude: -117.2510682
//            ),
//            images: [
//                BarImage(
//                    id: 901,
//                    image: "riptides_pb_1.jpg",
//                    caption: "Sports bar setup",
//                    uploaded_at: "2025-01-05T18:00:00Z"
//                ),
//                BarImage(
//                    id: 902,
//                    image: "riptides_pb_2.jpg",
//                    caption: "Game day atmosphere",
//                    uploaded_at: "2025-02-02T16:30:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 10,
//            name: "PB Avenue",
//            address: "4760 Mission Blvd, San Diego, CA 92109",
//            average_price: "$$",
//            location: Location(
//                latitude: 32.7977653,
//                longitude: -117.2506176
//            ),
//            images: [
//                BarImage(
//                    id: 1001,
//                    image: "pb_avenue_1.jpg",
//                    caption: "Front entrance",
//                    uploaded_at: "2025-02-10T19:15:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 11,
//            name: "Moonshine Beach",
//            address: "1165 Garnet Ave, San Diego, CA 92109",
//            average_price: "$$",
//            location: Location(
//                latitude: 32.7980179,
//                longitude: -117.2484153
//            ),
//            images: [
//                BarImage(
//                    id: 1101,
//                    image: "moonshine_beach_1.jpg",
//                    caption: "Country music night",
//                    uploaded_at: "2025-03-15T21:30:00Z"
//                ),
//                BarImage(
//                    id: 1102,
//                    image: "moonshine_beach_2.jpg",
//                    caption: "Line dancing",
//                    uploaded_at: "2025-04-01T22:00:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 12,
//            name: "PB Shore Club",
//            address: "4343 Ocean Blvd, San Diego, CA 92109",
//            average_price: "$$",
//            location: Location(
//                latitude: 32.7942403,
//                longitude: -117.2558471
//            ),
//            images: [
//                BarImage(
//                    id: 1201,
//                    image: "pb_shore_club_1.jpg",
//                    caption: "Ocean view from the bar",
//                    uploaded_at: "2025-01-25T16:45:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 13,
//            name: "Society PB",
//            address: "4755 Mission Blvd, San Diego, CA 92109",
//            average_price: "$$$",
//            location: Location(
//                latitude: 32.7975231,
//                longitude: -117.2506688
//            ),
//            images: [
//                BarImage(
//                    id: 1301,
//                    image: "society_pb_1.jpg",
//                    caption: "VIP section",
//                    uploaded_at: "2025-02-28T23:00:00Z"
//                ),
//                BarImage(
//                    id: 1302,
//                    image: "society_pb_2.jpg",
//                    caption: "DJ booth",
//                    uploaded_at: "2025-03-07T22:30:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 14,
//            name: "Lahaina Beach House",
//            address: "3920 Mission Blvd, San Diego, CA 92109",
//            average_price: "$",
//            location: Location(
//                latitude: 32.7916952,
//                longitude: -117.2551161
//            ),
//            images: [
//                BarImage(
//                    id: 1401,
//                    image: "lahaina_beach_house_1.jpg",
//                    caption: "Beachfront seating",
//                    uploaded_at: "2024-12-20T15:30:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 15,
//            name: "Break Point",
//            address: "945 Garnet Ave, San Diego, CA 92109",
//            average_price: "$$",
//            location: Location(
//                latitude: 32.7970878,
//                longitude: -117.2526739
//            ),
//            images: [
//                BarImage(
//                    id: 1501,
//                    image: "break_point_1.jpg",
//                    caption: "Pool tables",
//                    uploaded_at: "2025-03-25T20:15:00Z"
//                ),
//                BarImage(
//                    id: 1502,
//                    image: "break_point_2.jpg",
//                    caption: "Craft beer selection",
//                    uploaded_at: "2025-04-10T19:45:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 16,
//            name: "Dirty Birds",
//            address: "4656 Mission Blvd, San Diego, CA 92109",
//            average_price: "$$",
//            location: Location(
//                latitude: 32.7987627,
//                longitude: -117.2563120
//            ),
//            images: [
//                BarImage(
//                    id: 1601,
//                    image: "dirty_birds_1.jpg",
//                    caption: "Wing platter special",
//                    uploaded_at: "2025-02-05T18:15:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 17,
//            name: "bar Ella",
//            address: "725 Garnet Ave, San Diego, CA 92109",
//            average_price: "$$$",
//            location: Location(
//                latitude: 32.7976868,
//                longitude: -117.2512401
//            ),
//            images: [
//                BarImage(
//                    id: 1701,
//                    image: "bar_ella_1.jpg",
//                    caption: "Signature cocktails",
//                    uploaded_at: "2025-01-18T21:00:00Z"
//                ),
//                BarImage(
//                    id: 1702,
//                    image: "bar_ella_2.jpg",
//                    caption: "Upscale interior",
//                    uploaded_at: "2025-02-22T22:00:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 18,
//            name: "Alehouse",
//            address: "721 Grand Ave, San Diego, CA 92109",
//            average_price: "$$",
//            location: Location(
//                latitude: 32.7943251,
//                longitude: -117.2552584
//            ),
//            images: [
//                BarImage(
//                    id: 1801,
//                    image: "alehouse_1.jpg",
//                    caption: "Tap selection",
//                    uploaded_at: "2025-03-05T17:30:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 19,
//            name: "The Duck Dive",
//            address: "4650 Mission Blvd, San Diego, CA 92109",
//            average_price: "$$",
//            location: Location(
//                latitude: 32.7985307,
//                longitude: -117.2562483
//            ),
//            images: [
//                BarImage(
//                    id: 1901,
//                    image: "duck_dive_1.jpg",
//                    caption: "Brunch crowd",
//                    uploaded_at: "2025-01-12T11:45:00Z"
//                ),
//                BarImage(
//                    id: 1902,
//                    image: "duck_dive_2.jpg",
//                    caption: "Evening ambiance",
//                    uploaded_at: "2025-02-15T20:30:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 20,
//            name: "PB Local",
//            address: "809 Thomas Ave, San Diego, CA 92109",
//            average_price: "$",
//            location: Location(
//                latitude: 32.7936288,
//                longitude: -117.2541387
//            ),
//            images: [
//                BarImage(
//                    id: 2001,
//                    image: "pb_local_1.jpg",
//                    caption: "Local art on walls",
//                    uploaded_at: "2024-12-15T19:00:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 21,
//            name: "Firehouse",
//            address: "722 Grand Ave, San Diego, CA 92109",
//            average_price: "$$",
//            location: Location(
//                latitude: 32.7947949,
//                longitude: -117.2555755
//            ),
//            images: [
//                BarImage(
//                    id: 2101,
//                    image: "firehouse_1.jpg",
//                    caption: "Rooftop bar",
//                    uploaded_at: "2025-03-18T18:00:00Z"
//                ),
//                BarImage(
//                    id: 2102,
//                    image: "firehouse_2.jpg",
//                    caption: "Ocean sunset view",
//                    uploaded_at: "2025-03-30T19:15:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 22,
//            name: "Waterbar",
//            address: "4325 Ocean Blvd, San Diego, CA 92109",
//            average_price: "$$$",
//            location: Location(
//                latitude: 32.79393763764441,
//                longitude: -117.25568880504693
//            ),
//            images: [
//                BarImage(
//                    id: 2201,
//                    image: "waterbar_1.jpg",
//                    caption: "Seafood platter",
//                    uploaded_at: "2025-02-08T20:15:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 23,
//            name: "Tap Room",
//            address: "1269 Garnet Ave, San Diego, CA 92109",
//            average_price: "$$",
//            location: Location(
//                latitude: 32.79830577170787,
//                longitude: -117.24664621336298
//            ),
//            images: [
//                BarImage(
//                    id: 2301,
//                    image: "tap_room_1.jpg",
//                    caption: "Craft beer flight",
//                    uploaded_at: "2025-01-30T18:30:00Z"
//                ),
//                BarImage(
//                    id: 2302,
//                    image: "tap_room_2.jpg",
//                    caption: "Dartboard corner",
//                    uploaded_at: "2025-02-15T21:30:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 24,
//            name: "The Collective",
//            address: "1250 Garnet Ave, San Diego, CA 92109",
//            average_price: "$$$",
//            location: Location(
//                latitude: 32.7983731693196,
//                longitude: -117.24682047353912
//            ),
//            images: [
//                BarImage(
//                    id: 2401,
//                    image: "the_collective_1.jpg",
//                    caption: "Mixologist preparing drinks",
//                    uploaded_at: "2025-03-22T22:00:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 25,
//            name: "Baja Beach Cafe",
//            address: "4320 Ocean Blvd, San Diego, CA 92109",
//            average_price: "$$",
//            location: Location(
//                latitude: 32.793322191294415,
//                longitude: -117.25567834010458
//            ),
//            images: [
//                BarImage(
//                    id: 2501,
//                    image: "baja_beach_cafe_1.jpg",
//                    caption: "Beachfront dining",
//                    uploaded_at: "2025-04-05T16:30:00Z"
//                ),
//                BarImage(
//                    id: 2502,
//                    image: "baja_beach_cafe_2.jpg",
//                    caption: "Margarita flight",
//                    uploaded_at: "2025-04-15T17:45:00Z"
//                )
//            ]
//        ),
//        Bar(
//            id: 26,
//            name: "Bare Back Grill",
//            address: "4640 Mission Blvd, San Diego, CA 92109",
//            average_price: "$$",
//            location: Location(
//                latitude: 32.798274966357184,
//                longitude: -117.25623510971276
//            ),
//            images: [
//                BarImage(
//                    id: 2601,
//                    image: "bare_back_grill_1.jpg",
//                    caption: "New Zealand inspired burgers",
//                    uploaded_at: "2025-02-25T19:30:00Z"
//                )
//            ]
//        )
//    ]

    private let pacificBeachCoordinate = CLLocationCoordinate2D(
        latitude: 32.794,
        longitude: -117.253
    )

    init() {
        Task { await loadBarData() }
    }

    func loadBarData() async {
        let bars = await BarStatusService.shared.fetchBars()
        if let bars = bars {
            self.bars = bars
        } else {
            print("never found bars")
        }
//        do {
//            async let rawStatuses = BarStatusService.shared.fetchStatuses()
//            async let voteSummaries = BarStatusService.shared
//                .fetchVoteSummaries()
//            let (statusList, summaries) = try await (rawStatuses, voteSummaries)
//
//            let threshold = 1
//            var kept: [Int: BarStatus] = [:]
//            for st in statusList {
//                let count = summaries.filter { $0.bar == st.bar }.count
//                if count > threshold { kept[st.bar] = st }
//            }
//            statuses = kept
//        } catch {
//            print("Failed loading bar data:", error)
//        }
    }

    /// Loads music & pricing choices
    func loadMetadata() async {
        do {
            async let rawMusic = BarStatusService.shared.fetchMusic()
            async let rawPricing = BarStatusService.shared.fetchPricing()
            let (musicList, priceList) = try await (rawMusic, rawPricing)

            var mDict: [Int: String] = [:]
            for m in musicList { mDict[m.bar] = m.music }
            music = mDict

            var pDict: [Int: String] = [:]
            for p in priceList { pDict[p.bar] = p.price_range }
            pricing = pDict

        } catch {
            print("Failed loading metadata:", error)
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
