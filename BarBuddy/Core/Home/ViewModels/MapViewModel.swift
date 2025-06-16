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

    func updateCameraPosition(query: String, _ bars: [Bar]) {
        guard let coord = bars.first(where: { $0.name.contains(query) })?.coordinate else {
            return
        }
        cameraPosition = .region(
            .init(
                center: coord,
                latitudinalMeters: 300,
                longitudinalMeters: 300
            )
        )
    }
}
