//
//  MapViewModel.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/5/25.
//

import Foundation
@preconcurrency import _MapKit_SwiftUI

@MainActor
@Observable
final class MapViewModel {
    var lookAroundScene: MKLookAroundScene?
    var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    private var pacificBeachCoordinate: CLLocationCoordinate2D = .init(
        latitude: 32.794,
        longitude: -117.253
    )

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
                longitude: -117.256312
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
    ]

    private func fetchBarLocation(_ bar: String) async
        -> CLLocationCoordinate2D?
    {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = bar
        request.region = .init(
            center: pacificBeachCoordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )

        let result = try? await MKLocalSearch(request: request).start()

        return result?.mapItems.first?.placemark.coordinate
    }

    func updateCameraPosition(bar: String) async {
        guard let barLocation = await fetchBarLocation(bar) else { return }
        cameraPosition = .region(
            .init(
                center: barLocation,
                latitudinalMeters: 300,
                longitudinalMeters: 300
            )
        )
    }

    private func getUserLocation() async -> CLLocationCoordinate2D? {
        let updates = CLLocationUpdate.liveUpdates()

        do {
            let update = try await updates.first { @Sendable place in
                place.location?.coordinate != nil
            }
            return update?.location?.coordinate

        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
