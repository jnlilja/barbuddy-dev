//
//  VoteWaitTimeView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/7/25.
//

import SwiftUI

struct VoteWaitTimeView: View {
    @Binding var properties: ButtonProperties
    @Binding var bar: Bar
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

                VoteButtonView(text: "< 5 min", opacity: 0.06, properties: $properties, bar: $bar)
                VoteButtonView(text: "5 - 10 min", opacity: 0.1, properties: $properties, bar: $bar)
                VoteButtonView(text: "10 - 20 min", opacity: 0.2, properties: $properties, bar: $bar)
                VoteButtonView(text: "20 - 30 min", opacity: 0.3, properties: $properties, bar: $bar)
                VoteButtonView(text: "30 - 45 min", opacity: 0.4, properties: $properties, bar: $bar)
                VoteButtonView(text: "> 45 min", opacity: 0.5, properties: $properties, bar: $bar)
            
                Spacer()
            }
        }
        .onChange(of: properties.selectedOption) { _, _ in
            withAnimation {
                properties.showMenu = false
            }
        }
    }
}

#Preview {
    VoteWaitTimeView(properties: .constant(.init(selectedOption: false, showMenu: false, type: "wait")), bar: .constant(Bar(id: 1, name: "Test Bar", address: "123 Test St", averagePrice: "10", latitude: 37.774722, longitude: -122.418233, location: nil, usersAtBar: 10, currentStatus: nil, averageRating: "4.5", images: nil, currentUserCount: nil, activityLevel: nil)))
}
