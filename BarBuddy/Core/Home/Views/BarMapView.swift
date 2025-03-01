//
//  MapPreviewSection.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/26/25.
//

import MapKit
import SwiftUI

struct BarMapView: View {
    
    // Camera automatically follows user's location
    @State var userLocation: MapCameraPosition = .userLocation(
        fallback: .automatic)
    
    // Temporary location manager
    let locationManager = CLLocationManager()
    
    var body: some View {
        Map(position: $userLocation) {
            UserAnnotation()
        }
        .onAppear {
            
            // Request user location
            locationManager.requestWhenInUseAuthorization()
        }
        .mapControls {
            
            // Map control config
            MapCompass()
            MapUserLocationButton()
        }
        .tint(Color("Salmon"))
    }
}

#Preview {
    BarMapView()
}
