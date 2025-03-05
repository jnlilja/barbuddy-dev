import MapKit
import SwiftUI

struct MainFeedView: View {
    @State private var scrollOffset: CGFloat = 0
    @Binding var selectedTab: Int
    @Namespace private var animation  // For zoom transition into map
    @StateObject var camera = CameraModel()
    

    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {

                    // Background Color
                    Color(.darkBlue)
                        .ignoresSafeArea(.all)

                    ScrollView {
                        VStack(spacing: 0) {

                            // Track the scroll offset using a GeometryReader
                            GeometryReader { proxy in
                                Color.clear
                                    .preference(
                                        key: ScrollOffsetPreferenceKey.self,
                                        value: proxy.frame(in: .global).minY)
                            }

                            // Map View Section (stays at top)
                            NavigationLink {
                                BarMapView(state: .expanded)
                                    .environmentObject(camera)
                                    .navigationTransition(
                                        .zoom(sourceID: "Map", in: animation)
                                    )
                                    .toolbarVisibility(
                                        .hidden, for: .navigationBar)

                            } label: {
                                BarMapView(state: .shrink)
                                    .environmentObject(camera)
                                    .tint(Color("Salmon"))
                                    .frame(height: 300)
                                    .cornerRadius(15)
                                    .padding(.top)
                                    .matchedTransitionSource(
                                        id: "Map", in: animation
                                    )

                            }
                            // Scrollable content
                            VStack(spacing: 0) {
                                SearchBar()
                                    .padding()

                                // Bar List
                                VStack(spacing: 20) {
                                    ForEach(0..<5) { _ in
                                        BarCard(selectedTab: $selectedTab)
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                    // Updates scroll position
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) {
                        value in
                        Task { @MainActor in
                            scrollOffset = value
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackgroundVisibility(.automatic)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Pacific Beach")
                            .font(.title)
                            .fontDesign(.rounded)
                            .fontWeight(.heavy)

                            // Changes color when scrolled down
                            .foregroundStyle(
                                scrollOffset < 90 ? .darkPurple : .nude
                            )
                            .animation(
                                .easeInOut(duration: 0.3), value: scrollOffset)
                    }
                }
            }
        }
    }
}

#Preview("Main Feed") {
    MainFeedView(selectedTab: .constant(2))
}
