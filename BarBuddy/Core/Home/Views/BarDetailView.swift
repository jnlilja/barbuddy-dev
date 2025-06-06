//  BarDetailPopup.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//
import SwiftUI
import SDWebImageSwiftUI

struct BarDetailView: View {
    @Environment(MapViewModel.self) var viewModel
    @Environment(BarViewModel.self) var barViewModel
    @State var bar: Bar
    @State private var loadingState: HoursLoadingState = .loading
    @State private var waitButtonProperties = ButtonProperties(type: "wait")

    private var waitTime: String {
        barViewModel.statuses.first(where: { $0.bar == bar.id })?.waitTime ?? "No votes"
    }
    
    private var isClosed: Bool {
        barViewModel.hours.first(where: { $0.bar == bar.id })?.isClosed ?? true
    }

    var body: some View {
        if waitButtonProperties.showMenu && !waitButtonProperties.didSubmit {
            VoteSelectionView(properties: $waitButtonProperties, bar: $bar)
                .transition(.scale)

        } else {
            NavigationStack {
                VStack(spacing: 25) {
                    Spacer()
                    // MARK: — Header

                    // Make the bar name adapt to the screen size
                    Text(bar.name)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color("DarkPurple"))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                    
                    // MARK: — Wait time
                    VStack(spacing: 10) {
                        if !waitButtonProperties.didSubmit {
                            HStack {
                                Image(systemName: "clock.fill")
                                Text("Wait Time")
                            }
                            .foregroundColor(Color("DarkPurple"))
                            .font(.title2)
                            .bold()

                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(style: StrokeStyle(lineWidth: 2))
                                    .foregroundStyle(.neonPink.opacity(0.5))
                                    .frame(width: 180, height: 130)
                                    .background(.salmon.opacity(0.2))
                                    .cornerRadius(15)
                                    .shadow(radius: 10)

                                // MARK: — Loading state

                                switch loadingState {
                                case .loading:
                                    ProgressView()
                                        .tint(.darkPurple)
                                        .scaleEffect(1.5)
                                case .loaded:
                                    Text(waitTime)

                                case .failed:
                                    Text("Wait time unavailable")
                                        .frame(width: 150)
                                        .multilineTextAlignment(.center)
                                case .closed:
                                    Text("Closed")
                                }
                            }
                            .font(.title)
                            .foregroundColor(.darkPurple)
                            .bold()

                            Button {
                                withAnimation(
                                    .spring(duration: 0.5, bounce: 0.3)
                                ) {
                                    waitButtonProperties.showMenu = true
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(.darkPurple)
                                        .frame(width: 180, height: 120)
                                        .cornerRadius(15)
                                        .shadow(radius: 20)

                                    VStack {
                                        Text("Vote Wait Time!")
                                            .frame(width: 130)
                                            .font(.title)
                                            .bold()

                                        Image(systemName: "arrow.right")
                                            .foregroundStyle(.white)

                                    }
                                    .foregroundStyle(.white)
                                }
                            }
                            // Disable vote button if bar is closed or wait time could not be fetched
                            .disabled(
                                loadingState == .closed
                                || loadingState == .failed
                                || loadingState == .loading
                            )
                            .opacity(
                                loadingState == .closed
                                || loadingState == .failed ? 0.5 : 1
                            )
                            .padding(.top)
                            
                            Text("Voting has concluded for this bar.")
                                .foregroundColor(.neonPink)
                                .font(.caption)
                                .padding(.top, 5)
                                .opacity(loadingState == .closed ? 1 : 0)
                            
                        } else {
                            VoteConfirmedView()
                                .transition(.blurReplace)
                        }
                    }
                    Spacer()

                    VStack {
                        Text("Enjoying BarBuddy?")
                            .font(.title3)
                            .foregroundColor(Color("DarkPurple"))
                        Group {
                            Text("Follow us on IG for events and updates!")
                            Text("@barbuddy.pb")
                        }
                        .foregroundStyle(.darkBlue)
                        .font(.callout)
                        .bold()
                    }
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
            }
            .task {
                if isClosed {
                    loadingState = .closed; return
                }
                
                let cacheDate = UserDefaults.standard.object(forKey: "barVotes_cache_timestamp") as? Date
                let isCacheValid = cacheDate.map { Date().timeIntervalSince($0) < voteCacheExpiration } ?? false
                
                if let cachedStatus = barViewModel.statuses.first(where: { $0.bar == bar.id }), isCacheValid {
                    loadingState = .loaded
                    print("Using cached wait time: \(cachedStatus.waitTime)")
                    return
                }
                if cacheDate == nil {
                    print("No cached vote found, fetching new data...")
                } else {
                    print("Bar Vote Cache Expired, fetching new data...")
                }
                
                loadingState = .loading
                do {
                    try await barViewModel.getMostVotedWaitTime(barId: bar.id)
                    loadingState = .loaded
                    print("Most voted wait time fetched successfully.")
                    print("Wait time: \(waitTime)")
                    
                } catch {
                    print("Error fetching most voted wait time: \(error)")
                    loadingState = .failed
                }
            }
            .transition(.blurReplace)
        }
    }
}
#Preview("Bar is Open") {
    BarDetailView(
        bar: Bar.sampleBar
    )
    .environment(MapViewModel())
    .environment(BarViewModel.preview)
}

#Preview("Bar is Closed") {
    BarDetailView(
        bar: Bar.sampleBar
    )
    .environment(MapViewModel())
    .environment(BarViewModel.preview)
}
