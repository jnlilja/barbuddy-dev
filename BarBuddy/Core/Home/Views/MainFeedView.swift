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
    @StateObject private var viewModel = MapViewModel()
    @State private var bottomSheetPosition: BottomSheetPosition = .relative(0.86)
    @State private var selectedItem: UUID?
    @State private var selectedBar = false
    @State private var searchText = ""
    @Environment(\.colorScheme) var colorScheme
    let locationViewModel = LocationManager()

    private var selectedPlace: Bar? {
        guard let id = selectedItem else { return nil }
        return viewModel.bars.first { $0.id == id }
    }

    private var filteredBars: [Bar] {
        viewModel.bars.filter {
            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Map
                Map(position: $viewModel.cameraPosition, selection: $selectedItem) {
                    ForEach(viewModel.bars) { bar in
                        Annotation(bar.name, coordinate: bar.location) {
                            ZStack {
                                if bar.events.isEmpty {
                                    Circle()
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(.darkBlue)
                                } else {
                                    Circle()
                                        .stroke(lineWidth: 4)
                                        .frame(width: 30, height: 30)
                                        .background(.darkBlue)
                                        .clipShape(Circle())
                                        .foregroundStyle(Gradient(colors: [.salmon, .neonPink]))
                                }
                                Image(systemName: "wineglass.fill")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    UserAnnotation()
                }
                .onChange(of: selectedItem) { _, new in selectedBar = new != nil }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapPitchToggle()
                }
                .ignoresSafeArea(.keyboard)
                .onAppear { locationViewModel.startLocationServices() }
                .sheet(isPresented: $selectedBar) {
                    BarDetailPopup(name: selectedPlace?.name ?? "")
                }
                .tint(.salmon)

                // Bottom sheet
                .bottomSheet(
                    bottomSheetPosition: $bottomSheetPosition,
                    switchablePositions: [.relativeBottom(0.21), .relative(0.86), .relativeTop(1)],
                    headerContent: {
                        SearchBar(searchText: $searchText)
                            .padding([.horizontal, .bottom])
                            .onSubmit(of: .text) {
                                bottomSheetPosition = .relativeBottom(0.21)
                                Task { await viewModel.updateCameraPosition(bar: searchText) }
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                bottomSheetPosition = .relative(0.86)
                            })
                    }
                ) {
                    VStack {
                        NavigationLink(destination: DealsAndEventsView()) {
                            EventCard()
                                .padding([.horizontal, .bottom])
                        }
                        .buttonStyle(PlainButtonStyle())

                        if filteredBars.isEmpty {
                            Text("No results found")
                                .foregroundColor(.white)
                                .font(.title3)
                        } else {
                            ForEach(filteredBars) { bar in
                                BarCard(bar: bar)
                                    .padding([.horizontal, .bottom])
                            }
                            .transition(.opacity)
                            .animation(.easeInOut, value: searchText)
                        }
                    }
                }
                .customBackground(.darkBlue.opacity(0.9))
                .dragIndicatorColor(bottomSheetPosition == .relativeTop(1) ? .clear : .white)
                .enableAppleScrollBehavior()
                .customAnimation(.snappy)
                .ignoresSafeArea(.keyboard)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Pacific Beach")
                        .font(.title)
                        .fontDesign(.rounded)
                        .fontWeight(.heavy)
                        .foregroundStyle(
                            (colorScheme == .dark || bottomSheetPosition == .relativeTop(1))
                                ? .salmon : .darkBlue
                        )
                        .animation(.easeInOut, value: bottomSheetPosition)
                }
            }
        }
        .environmentObject(viewModel)
        .task { await viewModel.loadBarData() }
    }
}

struct MainFeedView_Previews: PreviewProvider {
    static var previews: some View {
        MainFeedView()
            .environmentObject(MapViewModel())
    }
}
