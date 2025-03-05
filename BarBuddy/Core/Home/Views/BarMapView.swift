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
    @State var state: ViewingMapState
    
    var body: some View {
        Map(position: $mapCameraPosition.cam,
            interactionModes: state == .expanded ? [.pan, .zoom, .rotate] : .pan) {
            UserAnnotation()
        }
        .onMapCameraChange {change in
            if mapCameraPosition.cam.positionedByUser && !mapCameraPosition.cam.followsUserLocation {
                mapCameraPosition.cam = .camera(change.camera)
            }
        }
        .mapControls {
            // Map control config
            MapUserLocationButton()
            MapCompass()
        }
        //.mapControlVisibility(state == .expanded ? .visible : .hidden)
        .tint(Color("Salmon"))
    }
}

#Preview {
    BarMapView(state: .expanded)
        .environmentObject(CameraModel())
}
