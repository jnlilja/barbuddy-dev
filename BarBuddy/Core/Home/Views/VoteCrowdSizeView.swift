//
//  VoteCrowdSizeView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/11/25.
//

import SwiftUI

struct VoteCrowdSizeView: View {
    @Binding var buttonProperties: ButtonProperties
    
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
                
                VoteButtonView(text: "🫥 Empty", opacity: 0.06, properties: $buttonProperties) {
                    
                }
                VoteButtonView(text: "🫤 Low", opacity: 0.1, properties: $buttonProperties) {
                    
                }
                VoteButtonView(text: "🙂 Moderate", opacity: 0.2, properties: $buttonProperties) {
                    
                }
                VoteButtonView(text: "✨ Busy", opacity: 0.3, properties: $buttonProperties) {
                    
                }
                VoteButtonView(text: "🎉 Crowded", opacity: 0.4, properties: $buttonProperties) {
                    
                }
                VoteButtonView(text: "🔥 Packed", opacity: 0.5, properties: $buttonProperties) {
                    
                }
            
                Spacer()
            }
        }
        .onChange(of: buttonProperties.selectedOption) { _, _ in
            withAnimation {
                buttonProperties.showMenu = false
            }
        }
    }
}

#Preview {
    VoteCrowdSizeView(buttonProperties: .constant(.init(selectedOption: false, showMenu: false, offset: 0, type: "crowd")))
}
