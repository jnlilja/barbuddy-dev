//
//  FriendCircleView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct FriendCircleView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color("DarkBlue")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        Text("Deals and Events")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        // Events Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Events")
                                .font(.system(size: 35, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            // Event Cards
                            EventCard(
                                title: "Fish Races",
                                location: "PB Shoreclub",
                                time: "Wednesdays // 8pm - Close"
                            )
                            
                            EventCard(
                                title: "Karaoke",
                                location: "PB Local",
                                time: "Wednesdays // 7pm - 10pm"
                            )
                            
                            EventCard(
                                title: "Trivia",
                                location: "Open Bar",
                                time: "Wednesdays // 6pm - 9pm"
                            )
                        }
                        
                        // Deals Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Deals")
                                .font(.system(size: 35, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            // Deal Cards
                            DealCard(
                                title: "Well Wednesday",
                                location: "Open Bar",
                                description: "$5 Shots all night!"
                            )
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}

struct EventCard: View {
    let title: String
    let location: String
    let time: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color("DarkPurple"))
            
            Text("@ \(location)")
                .font(.title2)
                .foregroundColor(Color("DarkPurple"))
            
            Text(time)
                .font(.headline)
                .foregroundColor(Color("DarkPurple"))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct DealCard: View {
    let title: String
    let location: String
    let description: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color("DarkPurple"))
            
            Text("@ \(location)")
                .font(.title2)
                .foregroundColor(Color("DarkPurple"))
            
            Text(description)
                .font(.headline)
                .foregroundColor(Color("DarkPurple"))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

#Preview("Deals and Events") {
    FriendCircleView()
}
