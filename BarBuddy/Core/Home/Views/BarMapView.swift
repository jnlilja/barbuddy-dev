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
    @EnvironmentObject var mapCameraPosition: CameraModel

    // Track stes of the mapview
    @State var state: ViewingMapState

    // Temporary location manager
    let locationManager = CLLocationManager()

    // When map is expanded, access to all features except pitch, panning only allowed when mapview is small
    var body: some View {
        Map(
            position: $mapCameraPosition.cam,
            interactionModes: state == .expanded ? [.pan, .zoom, .rotate] : .pan
        ) {
            UserAnnotation()
        }
        // Track changes in camera position
        .onMapCameraChange { change in
            if mapCameraPosition.cam.positionedByUser
                && !mapCameraPosition.cam.followsUserLocation
            {
                mapCameraPosition.cam = .camera(change.camera)
            }
        }
        .mapControls {
            // Map control config
            MapUserLocationButton()
            MapCompass()
        }
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
        }
        .mapControlVisibility(state == .expanded ? .visible : .hidden)
        .tint(Color("Salmon"))
    }
}

#Preview {
    BarMapView(state: .expanded)
        .environmentObject(CameraModel())
}
