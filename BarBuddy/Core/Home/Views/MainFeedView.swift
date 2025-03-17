//
//  MapPreviewSection.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/26/25.
//

import BottomSheet
import MapKit
import SwiftUI

struct MainFeedView: View {
    
    /* IMPORTANT:
        Set the coordinates to Latiude: 32.794 Longitude: -117.253 to see bars
        on the map in the simulator. There doesn't seem to be a way to do this
        in the preview.
     */

    // Camera automatically follows user's location
    @State var bottomSheetPosition: BottomSheetPosition = .relative(0.86)
    @State var selectedPlace: MKMapItem?
    @State var searchText = ""
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedBar: Bool = false
    @EnvironmentObject var viewModel: MapViewModel

    // Temporary location manager
    let locationManager = CLLocationManager()
    
    var filteredBars: [MKMapItem] {
        viewModel.results.filter({ $0.placemark.name?.localizedCaseInsensitiveContains(searchText) ?? false || searchText.isEmpty })
    }

    var body: some View {
        NavigationStack {
            Map(position: $viewModel.cameraPosition, selection: $selectedPlace) {
                
                // Display annotations for search results on map
                ForEach(viewModel.results, id: \.self) { result in
                    Marker(result.placemark.name ?? "", systemImage: "wineglass.fill", coordinate: result.placemark.coordinate)
                        .tint(.darkBlue)
                }
                
                // User's location marker on map
                UserAnnotation()
            }
            // Listening for changes for bar selection on map
            .onChange(of: selectedPlace) { oldValue, newValue in
                selectedBar = newValue != nil
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
            .sheet(isPresented: $selectedBar,
                   onDismiss: { withAnimation { selectedPlace = nil } },
                   content: { BarDetailPopup(name: selectedPlace?.placemark.name ?? "") })
            .tint(.salmon)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            
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
                            
                            Task {
                                await viewModel.updateCameraPosition(bar: searchText)
                            }
                        }
                        .simultaneousGesture(TapGesture()
                            .onEnded({
                                bottomSheetPosition = .relative(0.86)
                            }))
                    
                }) {
                    // Search Results
                    if filteredBars.isEmpty {
                        Text("No results found")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                    else {
                        ForEach(filteredBars, id: \.self) { bar in
                            if let name = bar.placemark.name {
                                BarCard(name: name)
                                    .padding([.horizontal, .bottom])
                            }
                        }
                        .transition(.opacity)
                        .animation(.easeInOut, value: searchText)
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
}

#Preview {
    MainFeedView(bottomSheetPosition: .relative(0.21))
        .environmentObject(MapViewModel())
}
