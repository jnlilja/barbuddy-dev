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
    @EnvironmentObject var viewModel: MapViewModel
    let bar: Bar
    @State private var waitButtonProperties = ButtonProperties(type: "wait")
    @State private var crowdButtonProperties = ButtonProperties(type: "crowd")
    // Helper to find this bar’s index in the viewModel
    private var idx: Int {
        viewModel.bars.firstIndex { $0.id == bar.id } ?? -1
    }
    // Dynamic values from your endpoints
    private var musicType: String {
        viewModel.music[idx] ?? "–"
    }
    private var crowdSize: String {
        viewModel.statuses[idx]?.crowd_size ?? "–"
    }
    private var priceRange: String {
        viewModel.pricing[idx] ?? "–"
    }
    private var waitTime: String {
        viewModel.statuses[idx]?.wait_time ?? "–"
    }
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // MARK: — Header
                VStack(spacing: 8) {
                    Text(bar.name)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color("DarkPurple"))
                    HStack {
                        Text("Open")
                            .foregroundColor(.red)
                        Text("11am – 2am")
                            .foregroundColor(Color("DarkPurple"))
                    }
                }
                // MARK: — Quick‑info bubbles (music, crowd, price)
                HStack(spacing: 15) {
                    InfoBubble(icon: "music.note", text: musicType)
                    InfoBubble(icon: "flame.fill", text: crowdSize)
                    InfoBubble(icon: "dollarsign.circle", text: priceRange)
                }
                // MARK: — Wait time & crowd voting
                HStack(spacing: 30) {
                    // Wait‑time section
                    VStack(spacing: 10) {
                        if !waitButtonProperties.selectedOption {
                            Text("Est. Wait Time:")
                                .font(.headline)
                                .foregroundColor(Color("DarkPurple"))
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.salmon.opacity(0.2))
                                    .frame(width: 131, height: 50)
                                Text(waitTime)
                                    .foregroundColor(Color("DarkPurple"))
                                    .bold()
                            }

                            Button {
                                // send vote with current values
                                Task {
                                    try? await BarStatusService.shared
                                        .submitVote(
                                            barId: idx,
                                            crowdSize: crowdSize,
                                            waitTime: waitTime
                                        )
                                    await viewModel.loadBarData()
                                }
                                withAnimation(
                                    .spring(duration: 0.5, bounce: 0.3)
                                ) {
                                    waitButtonProperties.showMenu = true
                                    crowdButtonProperties.showMenu = false
                                }

                            } label: {
                                Text("Vote wait time!")
                                    .bold()
                                    .underline()
                                    .foregroundColor(Color("DarkPurple"))
                            }
                            .disabled(waitButtonProperties.showMenu)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(
                                        Gradient(colors: [
                                            .neonPink, .darkBlue,
                                        ]).opacity(0.7)
                                    )
                                    .frame(width: 131, height: 110)

                                Text("Voted! 👍")
                                    .foregroundStyle(.darkBlue)
                                    .padding()
                                    .cornerRadius(15)
                                    .bold()
                            }
                            .transition(.scale)
                        }
                    }
                    // Crowd‑size section
                    if !crowdButtonProperties.selectedOption {
                        VStack(spacing: 10) {

                            Text("Crowd Size is:")
                                .font(.headline)
                                .foregroundColor(Color("DarkPurple"))
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.salmon.opacity(0.2))
                                    .frame(width: 131, height: 50)
                                HStack {
                                    Image(systemName: "flame.fill")
                                    Text(crowdSize)
                                }
                                .foregroundColor(Color("DarkPurple"))
                                .bold()
                            }
                            Button {
                                // send vote with current values
                                Task {
                                    try? await BarStatusService.shared
                                        .submitVote(
                                            barId: idx,
                                            crowdSize: crowdSize,
                                            waitTime: waitTime
                                        )
                                    await viewModel.loadBarData()
                                }
                                withAnimation(
                                    .spring(duration: 0.5, bounce: 0.3)
                                ) {
                                    crowdButtonProperties.showMenu = true
                                    waitButtonProperties.showMenu = false
                                }
                            } label: {
                                Text("Vote crowd size!")
                                    .bold()
                                    .underline()
                                    .foregroundColor(Color("DarkPurple"))
                            }
                            .disabled(crowdButtonProperties.showMenu)
                        }
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(
                                    Gradient(colors: [.neonPink, .darkBlue])
                                        .opacity(0.7)
                                )
                                .frame(width: 131, height: 110)

                            Text("Voted! 👍")
                                .foregroundStyle(.darkBlue)
                                .padding()
                                .cornerRadius(15)
                                .bold()
                        }
                        .transition(.scale)
                    }
                }
                WebImage(
                    url: URL(
                        string:
                            "https://media.istockphoto.com/id/1040303026/photo/draught-beer-in-glasses.jpg?s=612x612&w=0&k=20&c=MvDv_YtiG4l1bh9vNJv5Hyb-l8ZSCsMDbxutWnCh-78="
                    )
                )
                .resizable()
                .frame(width: 350, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 20))

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
        //        .presentationDetents([.large])
        //        .presentationDragIndicator(.visible)
        // MARK: — Remove old “Feedback” view; overlay existing vote menus
        .overlay {
            // Wait‑time menu
            if waitButtonProperties.showMenu {
                HStack {
                    VoteWaitTimeView(properties: $waitButtonProperties)
                        .offset(x: waitButtonProperties.offset)
                        .padding(.leading)
                        .gesture(
                            DragGesture(
                                minimumDistance: 0,
                                coordinateSpace: .local
                            )
                            .onChanged { value in
                                if value.translation.width <= 0 {
                                    withAnimation(.linear(duration: 0.1)) {
                                        waitButtonProperties.offset =
                                            value.translation.width
                                    }
                                }
                            }
                            .onEnded { _ in
                                if waitButtonProperties.offset < -100 {
                                    withAnimation(.snappy) {
                                        waitButtonProperties.showMenu = false
                                    }
                                }
                                withAnimation {
                                    waitButtonProperties.offset = 0
                                }
                            }
                        )
                    Spacer()
                }
                .transition(.move(edge: .leading))
            }
            // Crowd‑size menu
            if crowdButtonProperties.showMenu {
                HStack {
                    Spacer()
                    VoteCrowdSizeView(buttonProperties: $crowdButtonProperties)
                        .offset(x: crowdButtonProperties.offset)
                        .padding(.trailing)
                        .gesture(
                            DragGesture(
                                minimumDistance: 0,
                                coordinateSpace: .local
                            )
                            .onChanged { value in
                                if value.translation.width > 0 {
                                    withAnimation(.linear(duration: 0.1)) {
                                        crowdButtonProperties.offset =
                                            value.translation.width
                                    }
                                }
                            }
                            .onEnded { _ in
                                if crowdButtonProperties.offset > 100 {
                                    withAnimation(.snappy) {
                                        crowdButtonProperties.showMenu = false
                                    }
                                }
                                withAnimation {
                                    crowdButtonProperties.offset = 0
                                }
                            }
                        )
                }
                .transition(.move(edge: .trailing))
            }
        }
    }
}
//struct BarDetailPopup_Previews: PreviewProvider {
//    static var previews: some View {
//        BarDetailPopup(
//            bar: Bar(
//                name: "Hideaway",
//                location: CLLocationCoordinate2D(
//                    latitude: 32.7961859,
//                    longitude: -117.2558475
//                )
//            )
//        )
//        .environmentObject(MapViewModel())
//        .previewLayout(.sizeThatFits)
//    }
//}
