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
    @State var bar: Bar
    @State private var hours: String?

    @State private var waitButtonProperties = ButtonProperties(type: "wait")
    @State private var crowdButtonProperties = ButtonProperties(type: "crowd")

    // Dynamic values from your endpoints
    private var crowdSize: String {
        viewModel.statuses.first(where: { $0.bar == bar.id })?.crowdSize ?? "–"
    }
    private var waitTime: String {
        viewModel.statuses.first(where: { $0.bar == bar.id })?.waitTime ?? "-"
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
                        Text(bar.name)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color("DarkPurple"))
                        
                        HStack {
                            Text(hours ?? "Hours not available")
                                .foregroundColor(.neonPink)
                                .font(.headline)
                        }
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
                                .font(.title3)
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(style: StrokeStyle(lineWidth: 2))
                                        .foregroundStyle(.neonPink.opacity(0.5))
                                        .frame(width: 131, height: 50)
                                        .background(.salmon.opacity(0.2))
                                        .cornerRadius(15)
                                        .shadow(radius: 10)
                                    
                                    if hours?.contains("Closed") != nil {
                                        Text("Closed")
                                    } else {
                                        Text(waitTime)
                                    }
                                }
                                .foregroundColor(Color("DarkPurple"))
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
                                            .foregroundStyle(Gradient(colors: [
                                                .neonPink, .salmon
                                            ]))
                                            .frame(width: 190, height: 50)
                                            .opacity(0.5)
                                            .cornerRadius(15)
                                            .shadow(radius: 20)
                                        
                                        HStack {
                                            Text("Vote wait time!")
                                                .bold()
                                                .foregroundColor(Color("DarkPurple"))
                                            Image(systemName: "person.3.sequence.fill")
                                                .foregroundColor(Color("DarkPurple"))
                                                .font(.system(size: 20))
                                        }
                                    }
                                }
                                // Disable button if menu is open or no wait time available
//                                .disabled(waitButtonProperties.showMenu || waitTime == "-")
//                                .opacity(waitTime == "-" ? 0.5 : 1)
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
                        //                    } else {
                        //                        ZStack {
                        //                            RoundedRectangle(cornerRadius: 15)
                        //                                .foregroundStyle(
                        //                                    Gradient(colors: [.neonPink, .darkBlue])
                        //                                        .opacity(0.7)
                        //                                )
                        //                                .frame(width: 131, height: 110)
                        //
                        //                            Text("Voted! 👍")
                        //                                .foregroundStyle(.darkBlue)
                        //                                .padding()
                        //                                .cornerRadius(15)
                        //                                .bold()
                        //                        }
                        //                        .transition(.scale)
                        //                    }
                    //}
                    Spacer()
                    
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
                hours = await bar.getHours()
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
}
