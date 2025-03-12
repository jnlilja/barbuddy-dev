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
    @Binding var trigger: Bool
    var body: some View {
        Button {
            withAnimation {
                trigger = true
            }
                
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    trigger = false
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
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VoteButtonView(text: "10 - 20 min", opacity: 0.5, trigger: .constant(false))
}
