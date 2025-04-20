//
//  NoMessagesView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/20/25.
//

import SwiftUI

struct NoMessagesView: View {
    var body: some View {
        VStack {
            Text("It's quiet in here...")
                .font(.title)
                .foregroundColor(.white)
                .bold()
            Text("Say something to get things going!")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
    }
}

#Preview {
    NoMessagesView()
        .background(Color.darkBlue)
}
