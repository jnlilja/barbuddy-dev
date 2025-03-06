//
//  MapPreviewSection.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/26/25.
//

import BottomSheet
import MapKit
import SwiftUI

struct BarMapView: View {

    // Camera automatically follows user's location
    @State var camera: MapCameraPosition = .userLocation(fallback: .automatic)
    @State var bottomSheetPosition: BottomSheetPosition = .relative(0.86)
    @Environment(\.colorScheme) var colorScheme

    // Temporary location manager
    let locationManager = CLLocationManager()

    var body: some View {
        Map(
            position: $camera,
            interactionModes: .all
        ) {
            // User's location marker on map
            UserAnnotation()
        }
        .mapControls {
            // Map control config
            MapUserLocationButton()
            MapCompass()
            MapPitchToggle()
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
        }
        .tint(.salmon)
        
        // Bottom sheet view
        .bottomSheet(
            bottomSheetPosition: $bottomSheetPosition,
            switchablePositions: [
                .relativeBottom(0.21),
                .relative(0.83),
                .relativeTop(1),
            ]
            , headerContent: {
                SearchBar()
                    .padding([.horizontal, .bottom])
                    .simultaneousGesture(TapGesture()
                        .onEnded({
                            bottomSheetPosition = .relativeTop(0.83)
                        }))
                    
            }) {
            VStack {
                // Search Resualts
                ForEach(0..<10) { _ in
                    BarCard(selectedTab: .constant(0))
                        .padding([.horizontal, .bottom])
                }
            }
        }
        .customBackground(.darkBlue.opacity(0.9))
        .dragIndicatorColor(bottomSheetPosition == .relativeTop(1) ? .clear : .white)
        .enableAppleScrollBehavior()
        .customAnimation(.snappy)
        .ignoresSafeArea(.keyboard)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Pacific Beach")
                    .font(.title)
                    .fontDesign(.rounded)
                    .fontWeight(.heavy)

                    // Changes color of title when in dark mode or sheet view takes up full screen
                    .foregroundStyle(
                        colorScheme == .dark || bottomSheetPosition == .relativeTop(1)
                        ? .salmon : .darkBlue
                    )
                    .animation(.easeInOut, value: bottomSheetPosition)
            }
        }
    }
}

#Preview {
    BarMapView(bottomSheetPosition: .absolute(325))
}
