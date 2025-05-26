//
//  VoteWaitTimeView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/7/25.
//

import SwiftUI

struct VoteWaitTimeView: View {
    let bar: Bar
    @Binding var properties: ButtonProperties
    var body: some View {
        ZStack {

            RoundedRectangle(cornerRadius: 15)
                .stroke(style: StrokeStyle(lineWidth: 1))
                .background(Color(.systemBackground).cornerRadius(15))
                .foregroundStyle(Color(.darkBlue))
                .frame(width: 210, height: 470)
                .shadow(radius: 10)

            VStack {
                Spacer()

                Text("Vote wait time!")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.darkBlue)

                VoteButtonView(text: "< 5 min", opacity: 0.06, properties: $properties) {
                    createVote(waitTime: "<5 min")
                }
                VoteButtonView(text: "5 - 10 min", opacity: 0.1, properties: $properties) {
                    createVote(waitTime: "5-10 min")
                }
                VoteButtonView(text: "10 - 20 min", opacity: 0.2, properties: $properties) {
                    createVote(waitTime: "10-20 min")
                }
                VoteButtonView(text: "20 - 30 min", opacity: 0.3, properties: $properties) {
                    createVote(waitTime: "20-30 min")
                }
                VoteButtonView(text: "> 30 min", opacity: 0.4, properties: $properties) {
                    createVote(waitTime: ">30 min")
                }
//                VoteButtonView(text: "> 45 min", opacity: 0.5, properties: $properties) {
//                    createVote(waitTime: ">45 min")
//                }
            
                Spacer()
            }
        }
        .onChange(of: properties.selectedOption) { _, _ in
            withAnimation {
                properties.showMenu = false
            }
        }
    }
    
    func createVote(waitTime: String) {
        Task {
            let result = await BarStatusService.shared.createBarVote(bar: bar, waitTime: waitTime)
            if result {
                print("vote worked!")
            } else {
                print("vote failed!")
            }
        }
    }
}

#Preview {
    VoteWaitTimeView(bar: Bar(id: 1, name: "test", address: "test", average_price: "123", location: Location(latitude: 12, longitude: 12), images: []), properties: .constant(.init(selectedOption: false, showMenu: false, type: "wait")))
}
