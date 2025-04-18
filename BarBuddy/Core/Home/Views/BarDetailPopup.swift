//
//  BarDetailPopup.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

struct BarDetailPopup: View {
    @Environment(\.dismiss) var dismiss
    @State var name: String

    // State to hold the user's mood selection from the Feedback view
    @State private var selectedMood: Mood? = nil
    @State private var showSwipeView = false
    @State private var waitButtonProperties = ButtonProperties(type: "wait")
    @State private var crowdButtonProperties = ButtonProperties(type: "crowd")

    var body: some View {
        NavigationView {

            VStack(spacing: 25) {

                // Header with bar name and hours
                VStack(spacing: 8) {
                    Text(name)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color("DarkPurple"))

                    HStack {
                        Text("Open")
                            .foregroundColor(.red)
                        Text("11am - 2am")
                            .foregroundColor(Color("DarkPurple"))
                    }
                }

                // Quick info tags
                HStack(spacing: 15) {
                    InfoBubble(icon: "music.note", text: "House")
                    InfoBubble(icon: "flame.fill", text: "Packed")
                    InfoBubble(text: "$ 5 - 20")
                }

                // Wait time and crowd size sections
                HStack(spacing: 30) {
                    VStack(spacing: 10) {
                        if !waitButtonProperties.selectedOption {

                            Text("Est. Wait Time:")
                                .font(.headline)
                                .foregroundColor(Color("DarkPurple"))

                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.salmon.opacity(0.2))
                                    .frame(width: 131, height: 50)

                                Text("20 - 30 min")
                                    .padding()
                                    .cornerRadius(15)
                            }

                            Button {
                                withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
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
                                        .foregroundColor(
                                            Color("DarkPurple")
                                        )
                                    Text("Packed")
                                }
                                .padding()
                                .foregroundColor(Color("DarkPurple"))
                                .cornerRadius(15)
                            }

                            Button {
                                withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
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
                Spacer()
                // Feedback view integrated here
                Feedback(selectedMood: $selectedMood)

                // Navigation button to SwipeView
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

            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .overlay {
            if waitButtonProperties.showMenu {
                HStack {
                    VoteWaitTimeView(
                        properties: $waitButtonProperties)
                    .offset(x: waitButtonProperties.offset)
                    .padding(.leading)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged { value in
                                // Only able to swipe to the left
                                if value.translation.width <= 0 {
                                    withAnimation(.linear(duration: 0.1)) {
                                        waitButtonProperties.offset = value.translation.width
                                    }
                                }
                            }
                            .onEnded({ _ in
                                // View will close when swiped to the left
                                if waitButtonProperties.offset < -100 {
                                    withAnimation(.snappy) {
                                        waitButtonProperties.showMenu = false
                                    }
                                }
                                // Resets position when not swiped far enough
                                withAnimation {
                                    waitButtonProperties.offset = 0
                                }
                            }
                            )
                    )

                    Spacer()
                }
                .transition(.move(edge: .leading))
            }

            if crowdButtonProperties.showMenu {
                HStack {
                    Spacer()
                    VoteCrowdSizeView(
                        buttonProperties: $crowdButtonProperties)
                    .offset(x: crowdButtonProperties.offset)
                    .padding(.trailing)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged { value in
                                // Only able to swipe to the right
                                if value.translation.width > 0 {
                                    withAnimation(.linear(duration: 0.1)) {
                                        crowdButtonProperties.offset = value.translation.width
                                    }
                                }
                            }
                            .onEnded({ _ in
                                // View will close when swiped about halfways to the right
                                if crowdButtonProperties.offset > 100 {
                                    withAnimation(.snappy) {
                                        crowdButtonProperties.showMenu = false
                                    }
                                }
                                // Resets position when not swiped far enough
                                withAnimation {
                                    crowdButtonProperties.offset = 0
                                }
                            }
                            )
                    )
                }
                .transition(.move(edge: .trailing))
            }
        }
    }
}

#Preview("Bar Detail Popup") {
    BarDetailPopup(name: "Hideaway")
      .environmentObject(AuthViewModel())      // ← add this
}

