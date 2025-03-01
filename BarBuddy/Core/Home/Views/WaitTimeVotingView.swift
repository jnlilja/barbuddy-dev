//
//  WaitTimeVotingView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

// Update WaitTimeVotingView
struct WaitTimeVotingView: View {
    @Binding var isPresented: Bool
    @State private var selectedTime: String?
    
    let waitTimeOptions = [
        "<5min",
        "5 - 10 min",
        "10 - 20 min",
        "20 - 30 min",
        "30 - 45 min",
        ">45 min"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(waitTimeOptions, id: \.self) { time in
                Button(action: {
                    selectedTime = time
                    isPresented = false
                }) {
                    Text(time)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color("Salmon").opacity(0.2))
                        .foregroundColor(Color("DarkPurple"))
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .frame(width: 200)  // Fixed width for the popup
    }
}
