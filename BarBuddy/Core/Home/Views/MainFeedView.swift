//  MapPreviewSection.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/26/25.
//
import BottomSheet
import MapKit
import SwiftUI

struct MainFeedView: View {
    @Environment(MapViewModel.self) var viewModel
    @Environment(BarViewModel.self) var barViewModel
    @State private var bottomSheetPosition: BottomSheetPosition = .relative(
        0.86
    )
    @State private var searchText = ""
    @State private var hours: String?
    @Environment(\.colorScheme) var colorScheme
    let locationViewModel = LocationManager()
    @State private var selectedBar: Bar?
    
    private var filteredBars: [Bar] {
        barViewModel.bars.filter {
            searchText.isEmpty
                || $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            mapLayer
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
                .toolbar { toolbarContent }
                .bottomSheet(
                    bottomSheetPosition: $bottomSheetPosition,
                    switchablePositions: [
                        .relativeBottom(0.21), .relative(0.86), .relativeTop(1),
                    ],
                    headerContent: { headerView }
                ) {
                    contentList
                }
                .customBackground(.darkBlue.opacity(0.9))
                .dragIndicatorColor(
                    bottomSheetPosition == .relativeTop(1) ? .clear : .white
                )
                .enableContentDrag()
                .enableAppleScrollBehavior()
                .customAnimation(.snappy)
                .ignoresSafeArea(.keyboard)
        }
        .task {

            await barViewModel.loadBarData()
            
        }
        .environment(viewModel)
    }
    // MARK: — Map Layer
    private var mapLayer: some View {
        @Bindable var mapVM = viewModel
        return Map(position: $mapVM.cameraPosition, selection: $selectedBar) {
            ForEach(barViewModel.bars) { bar in
                Annotation(bar.name, coordinate: bar.coordinate) {
                    annotationView(for: bar)
                }
                .tag(bar)
            }
            UserAnnotation()
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapPitchToggle()
        }
        .ignoresSafeArea(.keyboard)
        .onAppear { locationViewModel.startLocationServices() }
        .sheet(
            item: $selectedBar,
            content: { BarDetailPopup(bar: $0) }
        )
        .tint(.salmon)
    }
    private func annotationView(for bar: Bar) -> some View {
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
    private var headerView: some View {
        SearchBar(searchText: $searchText, prompt: "Search bars")
            .padding([.horizontal, .bottom])
            .onSubmit(of: .text) {
                bottomSheetPosition = .relativeBottom(0.21)
                Task { await viewModel.updateCameraPosition(bar: searchText) }
            }
            .simultaneousGesture(
                TapGesture().onEnded {
                    bottomSheetPosition = .relative(0.86)
                }
            )
    }
    private var contentList: some View {
        VStack {
            NavigationLink(destination: DealsAndEventsView()) {
                DealsAndEventsButtonView()
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
                        .environment(viewModel)
                        .padding([.horizontal, .bottom])
                }
                .transition(.opacity)
                .animation(.easeInOut, value: searchText)
                
            }
        }
    }
    // MARK: — Toolbar
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Pacific Beach")
                .font(.title)
                .fontDesign(.rounded)
                .fontWeight(.heavy)
                .foregroundStyle(
                    (colorScheme == .dark
                        || bottomSheetPosition == .relativeTop(1))
                        ? .salmon : .darkBlue
                )
                .animation(.easeInOut, value: bottomSheetPosition)
        }
    }
}
#Preview {
    MainFeedView()
        .environment(MapViewModel())
        .environment(VoteViewModel())
        .environment(BarViewModel())
}
