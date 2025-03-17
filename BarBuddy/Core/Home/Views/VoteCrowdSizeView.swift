//
//  VoteCrowdSizeView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/11/25.
//

import SwiftUI

struct VoteCrowdSizeView: View {
    @Binding var selectedCrowd: Bool
    @Binding var showCrowdSizeView: Bool
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

                Text("Vote crowd size!")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.darkBlue)
                
                VoteButtonView(text: "🫥 Empty", opacity: 0.06, trigger: $selectedCrowd)
                VoteButtonView(text: "🫤 Low", opacity: 0.1, trigger: $selectedCrowd)
                VoteButtonView(text: "🙂 Moderate", opacity: 0.2, trigger: $selectedCrowd)
                VoteButtonView(text: "✨ Busy", opacity: 0.3, trigger: $selectedCrowd)
                VoteButtonView(text: "🎉 Crowded", opacity: 0.4, trigger: $selectedCrowd)
                VoteButtonView(text: "🔥 Packed", opacity: 0.5, trigger: $selectedCrowd)
            
                Spacer()
            }
        }
        .onChange(of: selectedCrowd) { _, _ in
            withAnimation {
                showCrowdSizeView = false
            }
        }
    }
}

#Preview {
    VoteCrowdSizeView(selectedCrowd: .constant(false), showCrowdSizeView: .constant(false))
}
