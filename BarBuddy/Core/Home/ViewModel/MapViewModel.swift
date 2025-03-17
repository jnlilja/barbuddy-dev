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
    private var pacificBeachCoordinate: CLLocationCoordinate2D = .init(latitude: 32.794, longitude: -117.253)
    
    // Query bars
    init() {
        Task {
            await fetchBars()
        }
    }
    
    func searchResults(for searchText: String) async {
        //if let userLocation = await getUserLocation() {
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText
            request.region = .init(center: pacificBeachCoordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
            
            let results = try? await MKLocalSearch(request: request).start()
            self.results.append(results?.mapItems.first ?? MKMapItem())
        //}
    }
    private func fetchBarLocation(_ bar: String) async -> CLLocationCoordinate2D? {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = bar
        request.region = .init(center: pacificBeachCoordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        
        let result = try? await MKLocalSearch(request: request).start()
        
        return result?.mapItems.first?.placemark.coordinate
    }
    
    func updateCameraPosition(bar: String) async {
        guard let barLocation = await fetchBarLocation(bar) else { return }
        cameraPosition = .region(.init(center: barLocation, latitudinalMeters: 500, longitudinalMeters: 500))
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
    private func fetchBars() async {
        async let _ = searchResults(for: "PB Shore Club")
        async let _ = searchResults(for: "Hideaway")
        async let _ = searchResults(for: "Firehouse PB")
        async let _ = searchResults(for: "The Local Pacific Beach")
        async let _ = searchResults(for: "Open Bar")
        async let _ = searchResults(for: "The Beverly Beach Garden")
        async let _ = searchResults(for: "Flamingo Deck")
        async let _ = searchResults(for: "Mavericks")
        async let _ = searchResults(for: "710")
        async let _ = searchResults(for: "Alehouse")
        async let _ = searchResults(for: "Lahaina Beach House")
        async let _ = searchResults(for: "Society")
        async let _ = searchResults(for: "Moonshine")
        async let _ = searchResults(for: "Duck Dive")
        async let _ = searchResults(for: "Dirty Birds")
        async let _ = searchResults(for: "Pacific Lounge")
        async let _ = searchResults(for: "PB Avenue")
        async let _ = searchResults(for: "Bar Ella")
        async let _ = searchResults(for: "Thrusters")
        async let _ = searchResults(for: "The Grass Skirt")
        async let _ = searchResults(for: "Riptides")
        async let _ = searchResults(for: "Break Point")
    }
}
