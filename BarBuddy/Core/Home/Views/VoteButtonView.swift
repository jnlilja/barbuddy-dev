//
//  VoteTimeButtonView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/11/25.
//

import SwiftUI

struct VoteButtonView: View {
    let text: String
    let opacity: Double
    @Binding var properties: ButtonProperties
    @Binding var bar: Bar

    var body: some View {
        Button {
           
            Task {
                do {
                    if let id = bar.id {
                        // Submit wait time
                        if properties.type == "wait" {
                            try await BarNetworkManager.shared.submitVote(
                                vote: BarVote(
                                    bar: id,
                                    waitTime: text,
                                    timeStamp: Date().formatted(
                                        date: .numeric,
                                        time: .standard
                                    )
                                )
                            )
                        } else {
                            // Submit crowd size
                            try await BarNetworkManager.shared.submitVote(
                                vote: BarVote(
                                    bar: id,
                                    waitTime: "",
                                    timeStamp: Date().formatted(
                                        date: .numeric,
                                        time: .standard
                                    )
                                )
                            )
                        }
                    }
                } catch {
                    print("Failed to submit vote: \(error)")
                }
            }
            withAnimation {
                properties.didSubmit = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    properties.didSubmit = false
                }
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 180, height: 50)
                    .foregroundStyle(.darkPurple)
                    .cornerRadius(15)
                    .opacity(opacity)

                Text(text)
                    .font(.headline)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .foregroundColor(.darkBlue)
            }
            .padding(.vertical, 5)
        }
        .highPriorityGesture(
            DragGesture()
                .onChanged { value in
                    if properties.type == "wait" {
                        // Only able to swipe to the left
                        if value.translation.width <= 0 {
                            withAnimation(.linear(duration: 0.1)) {
                                properties.offset = value.translation.width
                            }
                        }
                    } else {
                        // Only able to swipe to the right
                        if value.translation.width > 0 {
                            withAnimation(.linear(duration: 0.1)) {
                                properties.offset = value.translation.width
                            }
                        }
                    }
                }
                .onEnded({ _ in

                    // Dragging the menu from the button doesn't require as much travel to close menu

                    if properties.type == "wait" {
                        // View will close when swiped to the left
                        if properties.offset < -50 {
                            withAnimation(.snappy) {
                                properties.showMenu = false
                            }
                        }
                    } else {
                        // View will close when swiped about halfways to the right
                        if properties.offset > 50 {
                            withAnimation(.snappy) {
                                properties.showMenu = false
                            }
                        }
                    }
                    // Resets position when not swiped far enough
                    withAnimation {
                        properties.offset = 0
                    }
                }
                )
        )
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VoteButtonView(
        text: "10 - 20 min",
        opacity: 0.5,
        properties: .constant(
            .init(
                didSubmit: false,
                showMenu: false,
                offset: 0,
                type: "wait"
            )
        ),
        bar: .constant(
            Bar(
                name: "Test Bar",
                address: "Test Address",
                latitude: 0,
                longitude: 0
            )
        )
    )
}
