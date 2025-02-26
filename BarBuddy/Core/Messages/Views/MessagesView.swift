//
//  MessagesView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct MessagesView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color("DarkBlue")  // Dark blue background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    Text("Connections")
                        .font(.system(size: 45, weight: .bold))  // Larger font
                        .foregroundColor(.white)  // Changed to white for contrast
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    ScrollView {
                        VStack(spacing: 25) {  // Increased spacing
                            // Groups Section
                            VStack(alignment: .leading, spacing: 20) {  // Increased spacing
                                Text("Groups")
                                    .font(.system(size: 30))  // Larger font
                                    .foregroundColor(.white)
                                    .bold()
                                
                                // Group Cards
                                GroupChatCard(
                                    groupName: "Golden Girls 💕",
                                    message: "This app is insane",
                                    memberImages: ["guy1", "guy2", "guy3"]
                                )
                                
                                GroupChatCard(
                                    groupName: "Alcoholics",
                                    message: "How many features are on...",
                                    memberImages: ["guy1", "guy2", "guy3"]
                                )
                            }
                            .padding(.horizontal)
                            
                            // Direct Messages
                            VStack(spacing: 20) {  // Increased spacing
                                ForEach(["Bailey", "Ashley", "Johnny", "Sam"], id: \.self) { name in
                                    DirectMessageRow(
                                        name: name,
                                        message: name == "Bailey" ? "just sent you a drink :)" :
                                                name == "Ashley" ? "We r going to Shoreclub!" :
                                                name == "Johnny" ? "You go to UCSD?" : "u going out tn",
                                        location: name == "Bailey" ? "Shoreclub" :
                                                 name == "Ashley" ? "Hideaway" :
                                                 name == "Sam" ? "Hideaway" : nil
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top)
                    }
                }
            }
        }
    }
}
