//
//  VoteCrowdSizeView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/11/25.
//

import SwiftUI

struct VoteCrowdSizeView: View {
    @Binding var buttonProperties: ButtonProperties
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

                Text("Vote crowd size!")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.darkBlue)
                
                VoteButtonView(text: "🫥 Empty", opacity: 0.06, properties: $buttonProperties, bar: $bar)
                VoteButtonView(text: "🫤 Low", opacity: 0.1, properties: $buttonProperties, bar: $bar)
                VoteButtonView(text: "🙂 Moderate", opacity: 0.2, properties: $buttonProperties, bar: $bar)
                VoteButtonView(text: "✨ Busy", opacity: 0.3, properties: $buttonProperties, bar: $bar)
                VoteButtonView(text: "🎉 Crowded", opacity: 0.4, properties: $buttonProperties, bar: $bar)
                VoteButtonView(text: "🔥 Packed", opacity: 0.5, properties: $buttonProperties, bar: $bar)
            
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
    VoteCrowdSizeView(buttonProperties: .constant(.init(selectedOption: false, showMenu: false, offset: 0, type: "crowd")), bar: .constant(Bar(name: "", address: "", latitude: 3, longitude: 3)))
}
