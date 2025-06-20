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
    @State private var password = ""
    @State private var selectedBar: Bar?
    @State private var actions = MainFeedActions()
    
    @FocusState private var isFocused: Bool
    
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
                .toolbar { pacificBeachHeader; logOutButton }
                .bottomSheet(
                    bottomSheetPosition: $bottomSheetPosition,
                    switchablePositions: [
                        .relativeBottom(0.21), .relative(0.86), .relativeTop(1),
                    ],
                    headerContent: { headerView }
                ) {
                    if searchText.isEmpty {
                        contentList
                    } else {
                        SearchResultsView(
                            searchText: $searchText,
                            isLoading: $actions.isLoading,
                            position: $bottomSheetPosition,
                            focus: _isFocused
                        )
                    }
                }
                .customBackground(.darkBlue.opacity(0.9))
                .dragIndicatorColor(
                    bottomSheetPosition == .relativeTop(1) ? .clear : .white
                )
                .ignoresSafeArea(.keyboard)
                .sensoryFeedback(trigger: actions.showSettings) {
                    // Only apply haptics when tapped on logout icon
                    return $1 ? .selection : .none
                }
                .disabled(actions.showDeleteAlert)
        }
        .alert("Sign Out Error", isPresented: $actions.showDeleteErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: { Text("There was an error signing you out.") }
        .task {
            if barViewModel.bars.isEmpty {
                do {
                    try await barViewModel.loadBarData()
                    actions.isLoading = false
                } catch {
                    actions.isErrorPresented = true
                }
            }
            actions.isLoading = false
        }
        .sheet(isPresented: $actions.showSettings) {
            HStack {
                VStack(alignment: .leading, spacing: 16) {
                    if let email = authViewModel.authUser?.email {
                        Text("\(Text("Email").bold()): \(email)")
                            .padding(.top)
                    }
                    Spacer()

                    Button {
                        actions.showSignOutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "figure.walk.departure")
                            Text("Sign Out")
                        }
                        .foregroundStyle(colorScheme == .dark ? .salmon : .darkBlue)
                    }
                    
                    Divider()
                    
                    Button {
                        withAnimation {
                            actions.showDeleteAlert = true
                        }
                        actions.showSettings = false
                    } label: {
                        Image(systemName: "trash")
                        Text("Delete Account")
                    }
                    .tint(.red)
                    
                    Divider()
                    
                    Spacer()
                }
                .padding(.leading)
                .presentationDetents([.fraction(0.25)])
                .presentationDragIndicator(.visible)
                
                Spacer()
                
            }
        }
        .overlay {
            if actions.showDeleteAlert {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    DeletePromptView(password: $password, actions: $actions)
                        .transition(.blurReplace)
                }
            }
        }
        .tint(.salmon)
        .environment(viewModel)
        .alert("Are You Sure?", isPresented: $actions.showDeleteConfirmationAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        try await authViewModel.deleteUser(password: password)
                    } catch {
                        actions.showDeleteErrorAlert = true
                    }
                }
            }
        } message: {
            Text("This action cannot be undone. Your account will be permanently deleted.")
        }
        .alert("Error Loading Data", isPresented: $actions.isErrorPresented) {
            Button("Retry") {
                actions.isLoading = true
                Task {
                    do {
                        try await barViewModel.loadBarData()
                        actions.toggleBarError = false
                    } catch {
                        actions.isErrorPresented = true
                    }
                    actions.isLoading = false
                }
            }
            Button("Cancel", role: .cancel) {
                actions.toggleBarError = true
            }
        } message: {
            Text("There was an error loading the bar data. Please try again.")
        }
        .alert("Confirm Sign Out", isPresented: $actions.showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out") {
                URLCache.shared.removeAllCachedResponses()
                UserDefaults.standard.removeObject(forKey: "barStatuses_cache_timestamp")
                UserDefaults.standard.removeObject(forKey: "barHours_cache_timestamp")
                barViewModel.stopStatusRefreshTimer()
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
        .scaleEffect(selectedBar == bar ? 1.7 : 1)
        .animation(.snappy(extraBounce: 0.5), value: selectedBar)
    }
    private var headerView: some View {
        SearchBarView(searchText: $searchText, prompt: "Where to drink?", position: $bottomSheetPosition)
            .padding([.horizontal, .bottom])
            .simultaneousGesture(TapGesture().onEnded({ _ in
                actions.showSearchView = true
            }))
            .focused($isFocused)
            .scrollDismissesKeyboard(.automatic)
            .onSubmit(of: .text) {
                bottomSheetPosition = searchText.isEmpty ? .relative(0.86) : .relativeBottom(0.21)
                viewModel.updateCameraPosition(query: searchText, filteredBars)
            }
    }
    private var contentList: some View {
        ScrollView {
            VStack(spacing: 0) {
                GeometryReader { geometryProxy in
                    let minY = geometryProxy.frame(in: .named("scrollViewCoordinateSpace")).minY
                    Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: minY)
                }
                .frame(height: 0)
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offsetValue in
                    actions.isSwipingUP = offsetValue < 0.0
                }
                
                NavigationLink(destination: DealsAndEventsView()) {
                    DealsAndEventsButtonView()
                        .padding([.horizontal, .bottom])
                }
                .buttonStyle(.plain)
                
                if actions.isLoading {
                    ForEach(0..<3) { _ in
                        SkeletonBarCardView()
                    }
                    .padding([.horizontal, .bottom])
                } else {
                    if actions.toggleBarError || actions.isErrorPresented {
                        Button {
                            actions.isLoading = true
                            Task {
                                do {
                                    try await barViewModel.loadBarData()
                                    actions.isLoading = false
                                    actions.toggleBarError = false
                                } catch {
                                    actions.isLoading = false
                                }
                            }
                        } label: {
                            Text("Could not load bars. Please try again.")
                                .foregroundColor(.neonPink)
                                .bold()
                                .padding(.top, 20)
                        }
                    } else {
                        ForEach(barViewModel.bars) { bar in
                            BarCardView(bar: bar)
                                .environment(viewModel)
                                .padding([.horizontal, .bottom])
                                .transition(.blurReplace)
                                .scrollTransition { barCard, phase in
                                    barCard
                                        .scaleEffect(phase == .bottomTrailing ? 0.95 : 1)
                                }
                        }
                    }
                }
            }
        }
        .safeAreaPadding(.bottom, 90)
        .scrollDismissesKeyboard(.immediately)
        .coordinateSpace(name: "scrollViewCoordinateSpace")
        .simultaneousGesture(
            DragGesture().onEnded { gesture in
                // Check if scrolled to top and it's a clear swipe up
                if actions.isSwipingUP  {
                    self.bottomSheetPosition = .relativeTop(1)
                }
            }
        )
    }
    // MARK: — Toolbar
    private var pacificBeachHeader: some ToolbarContent {
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
    private var logOutButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                actions.showSettings = true
            } label: {
                //
                if #available(iOS 26, *) {
                    Image(systemName: "line.3.horizontal")

                } else {
                    Image(systemName: "line.3.horizontal")
                        .frame(width: 43, height: 43)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(RoundedCorner(radius: 10))
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
            .font(.callout)
            .foregroundStyle(
                colorScheme == .dark
                ? .salmon : .darkPurple
            )
        }
    }
}

#if DEBUG
#Preview {
    MainFeedView()
        .environment(MapViewModel())
        .environment(BarViewModel.preview)
        .environmentObject(AuthViewModel())
}
#endif
