//
//  VoteBoxButtonView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/21/25.
//

import SwiftUI

struct VoteButtonView: View {
    @Environment(\.colorScheme) var colorScheme
    let text: String
    let opacity: Double
    @Binding var properties: ButtonProperties
    @Binding var selectedOption: String?

    var body: some View {
        Button {
            withAnimation {
                selectedOption = text
            }
        } label: {
            ZStack {
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 120, height: 120)
                        .foregroundStyle(selectedOption == text ? .neonPink : .nude)
                        .cornerRadius(15)
                        .opacity(opacity)
                    
                    Text(text)
                        .font(.headline)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundColor(selectedOption == text ? .salmon : .nude)
                } else {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 120, height: 120)
                        .foregroundStyle(selectedOption == text ? .darkBlue : .salmon)
                        .cornerRadius(15)
                        .opacity(opacity)
                    
                    Text(text)
                        .font(.headline)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundColor(selectedOption == text ? .darkPurple : .darkBlue)
                }
            }
            .padding(.vertical, 5)
        }
    }
}

#Preview {
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
        selectedOption: .constant("")
    )
}
