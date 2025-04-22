//  MapPreviewSection.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/26/25.
//
import BottomSheet
import MapKit
import SwiftUI
struct MainFeedView: View {
    @EnvironmentObject var viewModel: MapViewModel
    @State private var bottomSheetPosition: BottomSheetPosition = .relative(0.86)
    @State private var selectedItem: UUID?
    @State private var isDetailPresented = false
    @State private var searchText = ""
    @Environment(\.colorScheme) var colorScheme
    let locationViewModel = LocationManager()
    var body: some View {
        NavigationStack {
            ZStack {
                mapLayer
                sheetLayer
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .toolbar { toolbarContent }
        }
        .environmentObject(viewModel)
        .task { await viewModel.loadBarData() }
    }
    // MARK: — Map Layer
    private var mapLayer: some View {
        Map(position: $viewModel.cameraPosition, selection: $selectedItem) {
            ForEach(viewModel.bars) { bar in
                Annotation(bar.name, coordinate: bar.location) {
                    annotationView(for: bar)
                }
            }
            UserAnnotation()
        }
        .onChange(of: selectedItem) { _, new in
            isDetailPresented = new != nil
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapPitchToggle()
        }
        .ignoresSafeArea(.keyboard)
        .onAppear { locationViewModel.startLocationServices() }
        .sheet(isPresented: $isDetailPresented) {
            if let bar = selectedBar {
                BarDetailPopup(bar: bar)
                    .environmentObject(viewModel)
            }
        }
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
    private var selectedBar: Bar? {
        guard let id = selectedItem else { return nil }
        return viewModel.bars.first { $0.id == id }
    }
    // MARK: — Bottom Sheet Layer
    private var sheetLayer: some View {
        Map(position: .constant(.userLocation(fallback: .automatic)), selection: .constant(nil)) { }
            .hidden()
            .bottomSheet(
                bottomSheetPosition: $bottomSheetPosition,
                switchablePositions: [.relativeBottom(0.21), .relative(0.86), .relativeTop(1)],
                headerContent: { headerView }
            ) {
                contentList
            }
            .customBackground(.darkBlue.opacity(0.9))
            .dragIndicatorColor(bottomSheetPosition == .relativeTop(1) ? .clear : .white)
            .enableAppleScrollBehavior()
            .customAnimation(.snappy)
            .ignoresSafeArea(.keyboard)
    }
    private var headerView: some View {
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
    private var contentList: some View {
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
                    NavigationLink(destination: BarDetailPopup(bar: bar)
                                    .environmentObject(viewModel)) {
                        BarCard(bar: bar)
                            .environmentObject(viewModel)
                            .padding([.horizontal, .bottom])
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .transition(.opacity)
                .animation(.easeInOut, value: searchText)
            }
        }
    }
    private var filteredBars: [Bar] {
        viewModel.bars.filter {
            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    // MARK: — Toolbar
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Pacific Beach")
                .font(.title).fontDesign(.rounded).fontWeight(.heavy)
                .foregroundStyle(
                    (colorScheme == .dark || bottomSheetPosition == .relativeTop(1))
                        ? .salmon : .darkBlue
                )
                .animation(.easeInOut, value: bottomSheetPosition)
        }
    }
}
struct MainFeedView_Previews: PreviewProvider {
    static var previews: some View {
        MainFeedView()
            .environmentObject(MapViewModel())
    }
}
