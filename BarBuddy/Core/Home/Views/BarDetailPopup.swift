//  BarDetailPopup.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//
import SwiftUI
import SDWebImageSwiftUI

struct BarDetailPopup: View {
    @Environment(\.dismiss) var dismiss
    @Environment(MapViewModel.self) var viewModel
    @Environment(VoteViewModel.self) var voteViewModel
    @State var bar: Bar
    @State private var loadingState: HoursLoadingState = .loading
    @State private var waitButtonProperties = ButtonProperties(type: "wait")

    private var waitTime: String {
        viewModel.statuses.first(where: { $0.bar == bar.id })?.waitTime ?? ""
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
                    VStack {
                        // Make the bar name adapt to the screen size
                        Text(bar.name)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color("DarkPurple"))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                    }
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

                                case .noWaitTime:
                                    Text("No wait")

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
                                || loadingState == .failed
                                || loadingState == .loading ? 0.5 : 1
                            )
                            .padding(.top)

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
                if let hours = await bar.getHours() {
                    loadingState = hours.contains("Closed") ? .closed : .loading
                } else {
                    loadingState = .failed
                    return
                }

                do {
                    if let id = bar.id {
                        try await voteViewModel.calculateVotes(for: id)
                    }
                } catch {
                    print("Error calculating votes: \(error)")
                }

                if viewModel.statuses.isEmpty {
                    loadingState = .loading
                    print("No bar status data available")
                } else {
                    // Check if the bar data is available
                    loadingState = waitTime.isEmpty ? .noWaitTime : .loaded
                }
            }
            .transition(.blurReplace)
        }
    }
}
#Preview(traits: .sizeThatFitsLayout) {
    BarDetailPopup(
        bar: Bar(
            name: "Hideaway",
            address: "4474 Mission Blvd, San Diego, CA 92109",
            averagePrice: "$$",
            latitude: 32.7961859,
            longitude: -117.2558475,
            location: "",
            usersAtBar: 10,
            currentStatus: "",
            averageRating: "",
            currentUserCount: "",
            activityLevel: "Packed"
        )
    )
    .environment(MapViewModel())
    .environment(VoteViewModel())
}
