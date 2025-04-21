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
final class MapViewModel: ObservableObject {
    // MARK: – Published properties so SwiftUI updates when they change
    @Published var cameraPosition: MapCameraPosition = .userLocation(
        fallback: .automatic
    )
    @Published var statuses: [Int: BarStatus] = [:]  // now Equatable
    @Published var music: [Int: String] = [:]
    @Published var pricing: [Int: String] = [:]
    // MARK: – Static list of bars in Pacific Beach
    let bars: [Bar] = [
        Bar(
            name: "Mavericks Beach Club",
            location: CLLocationCoordinate2D(
                latitude: 32.7969526,
                longitude: -117.2543182
            )
        ),
        Bar(
            name: "Thrusters Lounge",
            location: CLLocationCoordinate2D(
                latitude: 32.7982187,
                longitude: -117.2558549
            )
        ),
        Bar(
            name: "710 Beach Club",
            location: CLLocationCoordinate2D(
                latitude: 32.7964687,
                longitude: -117.2565146
            )
        ),
        Bar(
            name: "Open Bar",
            location: CLLocationCoordinate2D(
                latitude: 32.7937602,
                longitude: -117.2547777
            )
        ),
        Bar(
            name: "The Grass Skirt",
            location: CLLocationCoordinate2D(
                latitude: 32.7955066,
                longitude: -117.2528919
            )
        ),
        Bar(
            name: "Hideaway",
            location: CLLocationCoordinate2D(
                latitude: 32.7961859,
                longitude: -117.2558475
            )
        ),
        Bar(
            name: "Flamingo Deck",
            location: CLLocationCoordinate2D(
                latitude: 32.7911123,
                longitude: -117.2540975
            )
        ),
        Bar(
            name: "The Beverly Beach Garden",
            location: CLLocationCoordinate2D(
                latitude: 32.7924436,
                longitude: -117.2544375
            )
        ),
        Bar(
            name: "Riptides Pb",
            location: CLLocationCoordinate2D(
                latitude: 32.7959306,
                longitude: -117.2510682
            )
        ),
        Bar(
            name: "PB Avenue",
            location: CLLocationCoordinate2D(
                latitude: 32.7977653,
                longitude: -117.2506176
            )
        ),
        Bar(
            name: "Moonshine Beach",
            location: CLLocationCoordinate2D(
                latitude: 32.7980179,
                longitude: -117.2484153
            )
        ),
        Bar(
            name: "PB Shore Club",
            location: CLLocationCoordinate2D(
                latitude: 32.7942403,
                longitude: -117.2558471
            )
        ),
        Bar(
            name: "Society PB",
            location: CLLocationCoordinate2D(
                latitude: 32.7975231,
                longitude: -117.2506688
            )
        ),
        Bar(
            name: "Lahaina Beach House",
            location: CLLocationCoordinate2D(
                latitude: 32.7916952,
                longitude: -117.2551161
            )
        ),
        Bar(
            name: "Break Point",
            location: CLLocationCoordinate2D(
                latitude: 32.7970878,
                longitude: -117.2526739
            )
        ),
        Bar(
            name: "Dirty Birds",
            location: CLLocationCoordinate2D(
                latitude: 32.7987627,
                longitude: -117.2563120
            )
        ),
        Bar(
            name: "bar Ella",
            location: CLLocationCoordinate2D(
                latitude: 32.7976868,
                longitude: -117.2512401
            )
        ),
        Bar(
            name: "Alehouse",
            location: CLLocationCoordinate2D(
                latitude: 32.7943251,
                longitude: -117.2552584
            )
        ),
        Bar(
            name: "The Duck Dive",
            location: CLLocationCoordinate2D(
                latitude: 32.7985307,
                longitude: -117.2562483
            )
        ),
        Bar(
            name: "PB Local",
            location: CLLocationCoordinate2D(
                latitude: 32.7936288,
                longitude: -117.2541387
            )
        ),
        Bar(
            name: "Firehouse",
            location: CLLocationCoordinate2D(
                latitude: 32.7947949,
                longitude: -117.2555755
            )
        ),
        Bar(
            name: "Waterbar",
            location: CLLocationCoordinate2D(
                latitude: 32.79393763764441,
                longitude: -117.25568880504693
            )
        ),
        Bar(
            name: "Tap Room",
            location: CLLocationCoordinate2D(
                latitude: 32.79830577170787,
                longitude: -117.24664621336298

            )
        ),
        Bar(
            name: "The Collective",
            location: CLLocationCoordinate2D(
                latitude: 32.7983731693196,
                longitude: -117.24682047353912

            )
        ),
        Bar(
            name: "Baja Beach Cafe",
            location: CLLocationCoordinate2D(
                latitude: 32.793322191294415,
                longitude: -117.25567834010458
            )
        ),
        Bar(
            name: "Bare Back Grill",
            location: CLLocationCoordinate2D(
                latitude: 32.798274966357184,
                longitude: -117.25623510971276
            )
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
        do {
            async let rawStatuses = BarStatusService.shared.fetchStatuses()
            async let voteSummaries = BarStatusService.shared
                .fetchVoteSummaries()
            let (statusList, summaries) = try await (rawStatuses, voteSummaries)

            let threshold = 1
            var kept: [Int: BarStatus] = [:]
            for st in statusList {
                let count = summaries.filter { $0.bar == st.bar }.count
                if count > threshold { kept[st.bar] = st }
            }
            statuses = kept
        } catch {
            print("Failed loading bar data:", error)
        }
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
