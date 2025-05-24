import MapKit
import SDWebImageSwiftUI
//  BarDetailPopup.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//
import SwiftUI

struct BarDetailPopup: View {
    @Environment(\.dismiss) var dismiss
    @Environment(MapViewModel.self) var viewModel
    @Environment(VoteViewModel.self) var voteViewModel
    @State var bar: Bar
    @State private var loadingState: HoursLoadingState = .loading
    @State private var waitButtonProperties = ButtonProperties(type: "wait")
    @State private var crowdButtonProperties = ButtonProperties(type: "crowd")

    // Dynamic values from your endpoints
    private var crowdSize: String {
        viewModel.statuses.first(where: { $0.bar == bar.id })?.crowdSize ?? ""
    }
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
                    VStack(spacing: 8) {
                        // Make the bar name adapt to the screen size
                        Text(bar.name)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color("DarkPurple"))
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                    }
                    // MARK: — Quick‑info bubbles (music, crowd, price)
                    /// Coming in a future update
                    
                    //                HStack(spacing: 15) {
                    //                    InfoBubble(icon: "record.circle", text: waitTime)
                    //                    InfoBubble(icon: "flame.fill", text: crowdSize)
                    //                    InfoBubble(icon: "dollarsign.circle", text: bar.averagePrice ?? "-")
                    //                }
                    // MARK: — Wait time & crowd voting
                    //HStack(spacing: 30) {
                        // Wait‑time section
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
                                    case .success:
                                        Text(waitTime)
                                            
                                    case .failure:
                                        Text("Unavailable")
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
                                        //crowdButtonProperties.showMenu = false
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
                                                //.font(.title)
                                                .foregroundStyle(.white)
                                                
                                        }
                                        .foregroundStyle(.white)
                                    }
                                }
                                // Disable button if menu is open or no wait time available
                                .disabled(waitTime.isEmpty)
                                .opacity(waitTime.isEmpty ? 0.5 : 1)
                                .padding(.top)
                                
                            } else {
                               VoteConfirmedView()
                                    .transition(.blurReplace)
                            }
                        }
                        // MARK: — Crowd size section
                        /// Coming in a future update
                        
                        // Crowd‑size section
                        //                    if !crowdButtonProperties.selectedOption {
                        //                        VStack(spacing: 10) {
                        //
                        //                            Text("Crowd Size is:")
                        //                                .font(.headline)
                        //                                .foregroundColor(Color("DarkPurple"))
                        //                            ZStack {
                        //                                RoundedRectangle(cornerRadius: 15)
                        //                                    .foregroundStyle(.salmon.opacity(0.2))
                        //                                    .frame(width: 131, height: 50)
                        //                                HStack {
                        //                                    Image(systemName: "flame.fill")
                        //                                    Text(crowdSize)
                        //                                }
                        //                                .foregroundColor(Color("DarkPurple"))
                        //                                .bold()
                        //                            }
                        //                            Button {
                        //                                withAnimation(
                        //                                    .spring(duration: 0.5, bounce: 0.3)
                        //                                ) {
                        //                                    crowdButtonProperties.showMenu = true
                        //                                    waitButtonProperties.showMenu = false
                        //                                }
                        //                            } label: {
                        //                                Text("Vote crowd size!")
                        //                                    .bold()
                        //                                    .underline()
                        //                                    .foregroundColor(Color("DarkPurple"))
                        //                            }
                        //                            .disabled(crowdButtonProperties.showMenu)
                        //                        }
                        //                    }
                    //}
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
                    
                    // MARK: — Swipe Navigation
                    NavigationLink(destination: SwipeView()) {
                        HStack {
                            Text("Swipe")
                            Image(systemName: "person.2.fill")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Salmon").opacity(0.2))
                        .foregroundColor(Color("DarkPurple"))
                        .cornerRadius(15)
                    }
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
            }
            .task {
                await viewModel.loadBarData()
                do {
                    if let id = bar.id {
                        try await voteViewModel.calculateVotes(for: id)
                    }
                } catch {
                    print("Error calculating votes: \(error)")
                }
                
                // Check if the bar data is available
                loadingState = waitTime.isEmpty ? .failure : .success
            }
            .transition(.blurReplace)
        }

        // MARK: — Remove old “Feedback” view; overlay existing vote menus
//        .overlay {
//            // Wait‑time menu
//            if waitButtonProperties.showMenu {
//                HStack {
//                    VoteWaitTimeView(properties: $waitButtonProperties, bar: $bar)
//                        .offset(x: waitButtonProperties.offset)
//                        .padding(.leading)
//                        .gesture(
//                            DragGesture(
//                                minimumDistance: 0,
//                                coordinateSpace: .local
//                            )
//                            .onChanged { value in
//                                if value.translation.width <= 0 {
//                                    withAnimation(.linear(duration: 0.1)) {
//                                        waitButtonProperties.offset =
//                                            value.translation.width
//                                    }
//                                }
//                            }
//                            .onEnded { _ in
//                                if waitButtonProperties.offset < -100 {
//                                    withAnimation(.snappy) {
//                                        waitButtonProperties.showMenu = false
//                                    }
//                                }
//                                withAnimation {
//                                    waitButtonProperties.offset = 0
//                                }
//                            }
//                        )
//                    Spacer()
//                }
//                .transition(.move(edge: .leading))
//            }
//            // Crowd‑size menu
//            if crowdButtonProperties.showMenu {
//                HStack {
//                    Spacer()
//                    VoteCrowdSizeView(buttonProperties: $crowdButtonProperties, bar: $bar)
//                        .offset(x: crowdButtonProperties.offset)
//                        .padding(.trailing)
//                        .gesture(
//                            DragGesture(
//                                minimumDistance: 0,
//                                coordinateSpace: .local
//                            )
//                            .onChanged { value in
//                                if value.translation.width > 0 {
//                                    withAnimation(.linear(duration: 0.1)) {
//                                        crowdButtonProperties.offset =
//                                            value.translation.width
//                                    }
//                                }
//                            }
//                            .onEnded { _ in
//                                if crowdButtonProperties.offset > 100 {
//                                    withAnimation(.snappy) {
//                                        crowdButtonProperties.showMenu = false
//                                    }
//                                }
//                                withAnimation {
//                                    crowdButtonProperties.offset = 0
//                                }
//                            }
//                        )
//                }
//                .transition(.move(edge: .trailing))
//            }
//        }
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
