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
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var bottomSheetPosition: BottomSheetPosition = .relative(0.86)
    @State private var searchText = ""
    @State private var hours: String?
    
    @State private var selectedBar: Bar?
    @State private var isLoading = true
    @State private var isErrorPresented = false
    @State private var toggleBarError = false
    @State private var showSignOutAlert: Bool = false
    
    let locationViewModel = LocationManager()
    
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
                .toolbar { toolbarContent; logOut }
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
                .isResizable()
                .ignoresSafeArea(.keyboard)
                .sensoryFeedback(trigger: showSignOutAlert) {
                    // Only apply haptics when tapped on logout icon
                    return $1 ? .selection : .none
                }
        }
        .task {
            if barViewModel.bars.isEmpty {
                do {
                    try await barViewModel.loadBarData()
                    isLoading = false
                } catch {
                    print("Error loading bar data: \(error)")
                    isErrorPresented = true
                }
            }
            isLoading = false
        }
        .tint(.salmon)
        .environment(viewModel)
        .alert("Error Loading Data", isPresented: $isErrorPresented) {
            Button("Retry") {
                isLoading = true
                Task {
                    do {
                        try await barViewModel.loadBarData()
                        toggleBarError = false
                    } catch {
                        print("Error loading bar data: \(error)")
                    }
                    isLoading = false
                }
            }
            Button("Cancel", role: .cancel) {
                toggleBarError = true
            }
        } message: {
            Text("There was an error loading the bar data. Please try again.")
        }
        .alert("Confirm Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out") {
                URLCache.shared.removeAllCachedResponses()
                UserDefaults.standard.removeObject(forKey: "barStatuses_cache_timestamp")
                UserDefaults.standard.removeObject(forKey: "barHours_cache_timestamp")
                authViewModel.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .tint(colorScheme == .dark ? .salmon : .darkPurple)
    }
    // MARK: — Map Layer
    var mapLayer: some View {
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
            content: { BarDetailView(bar: $0) }
        )
        .tint(.salmon)
    }
    private func annotationView(for bar: Bar) -> some View {
        ZStack {
            if BarEvent.allEvents.isEmpty {
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
            Image("cocktail")
                .resizable()
                .frame(width: 18, height: 18)
        }
    }
    private var headerView: some View {
        SearchBarView(searchText: $searchText, prompt: "Search bars")
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
            if isLoading {
                ForEach(0..<3) { _ in
                    SkeletonBarCardView()
                }
                .padding([.horizontal, .bottom])
            } else {
                if toggleBarError || isErrorPresented {
                    Button {
                        isLoading = true
                        Task {
                            do {
                                try await barViewModel.loadBarData()
                                isLoading = false
                                toggleBarError = false
                            } catch {
                                print("Error loading bar data: \(error)")
                                isLoading = false
                            }
                        }
                    } label: {
                        Text("Could not load bars. Please try again.")
                            .foregroundColor(.neonPink)
                            .bold()
                            .padding(.top, 20)
                    }
                } else if filteredBars.isEmpty {
                    Text("No results found")
                        .foregroundColor(.white)
                        .font(.title3)
                } else {
                    ForEach(filteredBars) { bar in
                        BarCardView(bar: bar)
                            .environment(viewModel)
                            .padding([.horizontal, .bottom])
                            .transition(
                                .opacity.combined(with: .move(edge: .bottom))
                            )
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: isLoading)
        .animation(.easeInOut(duration: 0.3), value: searchText)
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
    private var logOut: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                showSignOutAlert = true
            } label: {
                //
                if #available(iOS 26, *) {
                    Image(systemName: "rectangle.portrait.and.arrow.forward")
                        .environment(\.layoutDirection, .rightToLeft)
                        .font(.callout)
                        .foregroundStyle(
                            colorScheme == .dark
                            ? .salmon : .darkPurple
                        )
                        .shadow(radius: 5)
                        .animation(.easeInOut, value: bottomSheetPosition)
                } else {
                    Image(systemName: "rectangle.portrait.and.arrow.forward")
                        .environment(\.layoutDirection, .rightToLeft)
                        .font(.callout)
                        .foregroundStyle(
                            colorScheme == .dark
                            ? .salmon : .darkPurple
                        )
                        .frame(width: 43, height: 43)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(RoundedCorner(radius: 10))
                        .animation(.easeInOut, value: bottomSheetPosition)
                }
            }
        }
    }
}
#Preview {
    MainFeedView()
        .environment(MapViewModel())
        .environment(BarViewModel.preview)
        .environmentObject(AuthViewModel())
}
