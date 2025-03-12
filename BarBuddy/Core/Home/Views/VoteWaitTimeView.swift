//
//  VoteWaitTimeView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/7/25.
//

import SwiftUI

struct VoteWaitTimeView: View {
    @Binding var selectedTime: Bool
    @Binding var showVoteWaitTime: Bool
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

                VoteButtonView(text: "< 5 min", opacity: 0.06, trigger: $selectedTime)
                VoteButtonView(text: "5 - 10 min", opacity: 0.1, trigger: $selectedTime)
                VoteButtonView(text: "10 - 20 min", opacity: 0.2, trigger: $selectedTime)
                VoteButtonView(text: "20 - 30 min", opacity: 0.3, trigger: $selectedTime)
                VoteButtonView(text: "30 - 45 min", opacity: 0.4, trigger: $selectedTime)
                VoteButtonView(text: "> 45 min", opacity: 0.5, trigger: $selectedTime)
            
                Spacer()
            }
        }
        .onChange(of: selectedTime) { _, _ in
            withAnimation {
                showVoteWaitTime = false
            }
        }
    }
}

#Preview {
    VoteWaitTimeView(selectedTime: .constant(false), showVoteWaitTime: .constant(true))
}
