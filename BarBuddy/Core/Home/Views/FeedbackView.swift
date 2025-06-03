//
//  Feedback.swift
//  BarBuddy
//
//  Created by YourName on 3/5/25.
//

import SwiftUI

// Enum to represent the available moods
enum Mood: String, CaseIterable {
    case happy
    case neutral
    case sad
}

struct FeedbackView: View {
    // Bind the selected mood to the parent view
    @Binding var selectedMood: Mood?
    @State private var showThankYou = false
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Enjoying your time?")
                .font(.headline)
                .foregroundColor(Color("DarkPurple"))
            
            if showThankYou {
                Text("Thanks for the feedback!")
                    .font(.headline)
                    .foregroundColor(Color("DarkPurple"))
            } else {
                HStack(spacing: 20) {
                    Button(action: {
                        selectedMood = .happy
                        showThankYou = true
                    }) {
                        Image("happyIcon")  // Replace with your asset name or SF Symbol
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    
                    Button(action: {
                        selectedMood = .neutral
                        showThankYou = true
                    }) {
                        Image("neutralIcon") // Replace with your asset name or SF Symbol
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    
                    Button(action: {
                        selectedMood = .sad
                        showThankYou = true
                    }) {
                        Image("sadIcon") // Replace with your asset name or SF Symbol
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                }
            }
        }
    }
}

struct Feedback_Previews: PreviewProvider {
    @State static var previewMood: Mood? = nil
    static var previews: some View {
        FeedbackView(selectedMood: $previewMood)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
