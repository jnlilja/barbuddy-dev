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
    @State var bottomSheetPosition: BottomSheetPosition = .relative(0.86)
    @State var selectedPlace: MKMapItem?
    @State private var searchText = ""
    @Environment(\.colorScheme) var colorScheme
    @Bindable var viewModel = MapViewModel()

    // Temporary location manager
    let locationManager = CLLocationManager()

    var body: some View {
        Map(position: $viewModel.cameraPosition, selection: $selectedPlace) {
            
            // Display annotations for search results on map
            ForEach(viewModel.results, id: \.self) { result in
                Marker(result.placemark.name ?? "", systemImage: "mug.fill", coordinate: result.placemark.coordinate)
                    .tint(.darkBlue)
            }
            
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
            Task {
                
                // Querying bars
                await viewModel.searchResults(for: "PB Shore Club")
                await viewModel.searchResults(for: "Hideaway")
                await viewModel.searchResults(for: "Firehouse American Eatery & Lounge")
                await viewModel.searchResults(for: "The Local Pacific Beach")
            }
        }
        .tint(.salmon)
        
        // Bottom sheet view
        .bottomSheet(
            bottomSheetPosition: $bottomSheetPosition,
            switchablePositions: [
                .relativeBottom(0.21),
                .relative(0.86),
                .relativeTop(1),
            ]
            , headerContent: {
                SearchBar(searchText: $searchText)
                    .padding([.horizontal, .bottom])
                    .onSubmit(of: .text) {
                        bottomSheetPosition = .relativeBottom(0.21)
                        #warning("Incomplete search functionality")
                        Task {
                            // Search for bars and update camera position
                            await viewModel.searchResults(for: searchText)
                            await viewModel.updateCameraPosition()
                        }
                    }
                    .simultaneousGesture(TapGesture()
                        .onEnded({
                            bottomSheetPosition = .relative(0.86)
                        }))
                    
            }) {
            VStack {
                // Search Resualts
                ForEach(0..<4) { _ in
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
    BarMapView(bottomSheetPosition: .relative(0.21))
}
