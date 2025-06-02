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
// This ViewModel manages the map camera position based on the selected bar.
// It initializes with a default position over Pacific Beach and updates the camera
final class MapViewModel {
    @ObservationIgnored private static let pacificBeachCoordinate =
        CLLocationCoordinate2D(
            latitude: 32.794,
            longitude: -117.253
        )
    var cameraPosition: MapCameraPosition = .region(
        .init(
            center: pacificBeachCoordinate,
            span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )

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

    private func fetchBarLocation(_ bar: String) async -> CLLocationCoordinate2D? {
        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = bar
        req.region = .init(
            center: MapViewModel.pacificBeachCoordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        let result = try? await MKLocalSearch(request: req).start()
        return result?.mapItems.first?.placemark.coordinate
    }
}
