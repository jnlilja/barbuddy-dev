//  BarDetailPopup.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct BarDetailView: View {
    @Environment(BarViewModel.self) var barViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var loadingState: HoursLoadingState = .loading
    @State private var voteActions = VoteButtonState(type: "wait")
    @State private var timer: TimerManager
    let bar: Bar
    
    init(bar: Bar) {
        self.bar = bar
        self._timer = State(wrappedValue: TimerManager(id: bar.id))
    }

    private var waitTime: String? {
        barViewModel.statuses.first(where: { $0.bar == bar.id })?.waitTime
            .replacingOccurrences(of: "<", with: "< ")
            .replacingOccurrences(of: ">", with: "> ")
            .replacingOccurrences(of: "-", with: " - ")
    }
    
    private var isClosed: Bool? {
        barViewModel.hours.first(where: { $0.bar == bar.id })?.isClosed
    }

    var body: some View {
        @Bindable var timerInstance = timer
        if voteActions.showMenu && !voteActions.didSubmit {
            VoteSelectionView(timer: timer, actions: $voteActions, bar: bar)
                .transition(.scale)

        } else {
            VStack(spacing: 25) {
                Spacer()
                // MARK: — Header
                
                // Make the bar name adapt to the screen size
                Text(bar.name)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .salmon : .darkPurple)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                
                // MARK: — Wait time
                VStack(spacing: 10) {
                    if !voteActions.didSubmit {
                        HStack {
                            Image(systemName: "clock.fill")
                            Text("Wait Time")
                        }
                        .foregroundColor(colorScheme == .dark ? .nude : .darkPurple)
                        .font(.title2)
                        .bold()
                        
                        ZStack {
                            if colorScheme == .dark {
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(style: StrokeStyle(lineWidth: 2))
                                    .foregroundStyle(.nude.opacity(0.5))
                                    .frame(width: 180, height: 130)
                                    .background(.nude.opacity(0.15))
                                    .cornerRadius(15)
                                    .shadow(radius: 10)
                            } else {
                                // For light mode
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(style: StrokeStyle(lineWidth: 2))
                                    .foregroundStyle(.neonPink.opacity(0.5))
                                    .frame(width: 180, height: 130)
                                    .background(.salmon.opacity(0.2))
                                    .cornerRadius(15)
                                    .shadow(radius: 10)
                            }
                            
                            // MARK: — Loading state
                            
                            switch loadingState {
                            case .loading:
                                ProgressView()
                                    .tint(colorScheme == .dark ? .salmon :.darkPurple)
                                    .scaleEffect(1.5)
                            case .loaded:
                                Text(waitTime!)
                                
                            case .failed:
                                Text("Wait time unavailable")
                                    .frame(width: 150)
                                    .multilineTextAlignment(.center)
                            case .closed:
                                Text("Closed")
                            }
                        }
                        .font(.title)
                        .foregroundColor(colorScheme == .dark ? .nude : .darkPurple)
                        .bold()
                        
                        if timer.isActive {
                            TimerView(timer: timerInstance)
                                .padding(.top)
                                .environment(timer)
                                
                        } else {
                            Button {
                                withAnimation(
                                    .spring(duration: 0.5, bounce: 0.3)
                                ) {
                                    voteActions.showMenu = true
                                }
                            } label: {
                                ZStack {
                                    if colorScheme == .dark {
                                        RoundedRectangle(cornerRadius: 15)
                                            .foregroundStyle(.nude)
                                            .frame(width: 180, height: 120)
                                            .cornerRadius(15)
                                            .shadow(radius: 20)
                                    } else {
                                        // For light mode
                                        RoundedRectangle(cornerRadius: 15)
                                            .foregroundStyle(.darkPurple)
                                            .frame(width: 180, height: 120)
                                            .cornerRadius(15)
                                            .shadow(radius: 20)
                                    }
                                    
                                    VStack {
                                        Text("Vote Wait Time!")
                                            .frame(width: 130)
                                            .font(.title)
                                            .bold()
                                        
                                        Image(systemName: "arrow.right")
                                    }
                                    .foregroundStyle(colorScheme == .dark ? .darkBlue : .nude)
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
                        }
                        
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
                        .foregroundColor(colorScheme == .dark ? .neonPink : .darkPurple)
                    Group {
                        Text("Follow us on IG for events and updates!")
                        HStack {
                            Image("instagram-logo")
                            Text("@barbuddy.pb")
                        }
                        .onTapGesture {
                            let username = "barbuddy.pb"
                            let appURL = URL(string: "instagram://user?username=\(username)")!
                            let webURL = URL(string: "https://www.instagram.com/\(username)")!
                            
                            if UIApplication.shared.canOpenURL(appURL) {
                                UIApplication.shared.open(appURL)
                            } else {
                                UIApplication.shared.open(webURL)
                            }
                        }
                    }
                    .foregroundStyle(colorScheme == .dark ? .nude : .darkBlue)
                    .font(.callout)
                    .bold()
                }
                .padding(.bottom)
            }
            .onAppear {
                // DEBUG Bar info
                #if DEBUG
                print(bar)
                #endif
                
                // Only proceeds if the bar is currently not closed
                guard let isClosed, !isClosed else  {
                    loadingState = isClosed == nil ? .failed : .closed
                    return
                }
                
                if waitTime != nil {
                    loadingState = .loaded
                }
                else {
                    loadingState = .failed
                }
            }
            .transition(.blurReplace)
        }
    }
}

#if DEBUG
#Preview("Bar is Open") {
    BarDetailView(
        bar: Bar.sampleBar
    )
    .environment(BarViewModel.preview)
}

#Preview("Bar is Closed") {
    BarDetailView(
        bar: Bar.sampleBars[2]
    )
    .environment(BarViewModel.preview)
}
#endif
