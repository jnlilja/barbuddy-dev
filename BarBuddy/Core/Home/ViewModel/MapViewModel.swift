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
final class MapViewModel: ObservableObject {
    var results: [MKMapItem] = []
    var lookAroundScene: MKLookAroundScene?
    var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // Query bars
    init() {
        Task {
            await searchResults(for: "PB Shore Club")
            await searchResults(for: "Hideaway")
            await searchResults(for: "Firehouse American Eatery & Lounge")
            await searchResults(for: "The Local Pacific Beach")
        }
    }
    
    func searchResults(for searchText: String) async {
        if let userLocation = await getUserLocation() {
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText
            request.region = .init(center: userLocation, latitudinalMeters: 2000, longitudinalMeters: 2000)
            
            let results = try? await MKLocalSearch(request: request).start()
            self.results.append(results?.mapItems.first ?? MKMapItem())
        }
    }
    
    func updateCameraPosition() async {
        guard let userLocation = await getUserLocation() else { return }
        cameraPosition = .region(.init(center: userLocation, latitudinalMeters: 3000, longitudinalMeters: 3000))
    }
    
    private func getUserLocation() async -> CLLocationCoordinate2D? {
        let updates = CLLocationUpdate.liveUpdates()
        
        do {
            let update = try await updates.first { @Sendable place in
                place.location?.coordinate != nil
            }
            return update?.location?.coordinate
            
        }catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
