//
//  BarDetailPopup.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

struct BarDetailPopup: View {
    @Environment(\.dismiss) var dismiss
    @State var name: String
    
    // State to hold the user's mood selection from the Feedback view
    @State private var selectedMood: Mood? = nil
    @State private var showSwipeView = false
    @State private var showWaitTimeView = false
    @State private var showCrowdSizeView = false
    @State private var selectedCrowd = false
    @State var selectedTime: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    
                    // Header with bar name and hours
                    VStack(spacing: 8) {
                        Text(name)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color("DarkPurple"))
                        
                        HStack {
                            Text("Open")
                                .foregroundColor(.red)
                            Text("11am - 2am")
                                .foregroundColor(Color("DarkPurple"))
                        }
                    }
                    
                    // Friends avatars section
                    VStack(spacing: 10) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<5) { _ in
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Text("+6 of your friends are here!")
                            .foregroundColor(Color("DarkPurple"))
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    // Quick info tags
                    HStack(spacing: 15) {
                        InfoBubble(icon: "music.note", text: "House")
                        InfoBubble(icon: "flame.fill", text: "Packed")
                        InfoBubble(text: "$ 5 - 20")
                    }
                    
                    // Wait time and crowd size sections
                    HStack(spacing: 30) {
                        VStack(spacing: 10) {
                            if !selectedTime {
                                
                                Text("Est. Wait Time:")
                                    .font(.headline)
                                    .foregroundColor(Color("DarkPurple"))
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(.salmon.opacity(0.2))
                                        .frame(width: 131, height: 50)
                                    
                                    Text("20 - 30 min")
                                        .padding()
                                    //.background(Color("Salmon").opacity(0.2))
                                        .cornerRadius(15)
                                }
                                
                                Button {
                                    withAnimation {
                                        showWaitTimeView = true
                                    }
                                } label: {
                                    Text("Vote wait time!")
                                        .bold()
                                        .underline()
                                        .foregroundColor(Color("DarkPurple"))
                                    
                                }
                                .disabled(showWaitTimeView)
                            }
                            else {
                                ZStack {
                                    
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(Gradient(colors: [.neonPink, .darkBlue]).opacity(0.7))
                                        .frame(width: 131, height: 110)
                                    
                                    Text("Voted! 👍")
                                        .foregroundStyle(.darkBlue)
                                        .padding()
                                        .cornerRadius(15)
                                        .bold()
                                }
                                .transition(.scale)
                            }
                        }
                        
                        if !selectedCrowd {
                            VStack(spacing: 10) {
                                
                                Text("Crowd Size is:")
                                    .font(.headline)
                                    .foregroundColor(Color("DarkPurple"))
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(.salmon.opacity(0.2))
                                        .frame(width: 131, height: 50)
                                    HStack {
                                        Image(systemName: "flame.fill")
                                            .foregroundColor(Color("DarkPurple"))
                                        Text("Packed")
                                    }
                                    .padding()
                                    .foregroundColor(Color("DarkPurple"))
                                    .cornerRadius(15)
                                }
                                
                                Button {
                                    withAnimation {
                                        showCrowdSizeView = true
                                    }
                                }label: {
                                    Text("Vote crowd size!")
                                        .bold()
                                        .underline()
                                        .foregroundColor(Color("DarkPurple"))
                                }
                                .disabled(showCrowdSizeView)
                            }
                        }
                        else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(Gradient(colors: [.neonPink, .darkBlue]).opacity(0.7))
                                    .frame(width: 131, height: 110)
                                
                                Text("Voted! 👍")
                                    .foregroundStyle(.darkBlue)
                                    .padding()
                                    .cornerRadius(15)
                                    .bold()
                            }
                            .transition(.scale)
                        }
                    }
                    
                    // Crowd level graph
                    CrowdLevelGraph()
                    
                    // Feedback view integrated here
                    Feedback(selectedMood: $selectedMood)
                    
                    // Navigation button to SwipeView
                    NavigationLink(destination: SwipeView()) {
                        HStack {
                            Text("Swipe")
                            Image(systemName: "person.2.fill")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Salmon").opacity(0.2))
                        .foregroundColor(Color("DarkPurple"))
                        .cornerRadius(15)
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .overlay {
            if showWaitTimeView {
                HStack {
                    VoteWaitTimeView(selectedTime: $selectedTime, showVoteWaitTime: $showWaitTimeView)
                        .padding(.leading)
                        
                    Spacer()
                }
                .transition(.move(edge: .leading))
            }
            
            if showCrowdSizeView {
                HStack {
                    Spacer()
                    VoteCrowdSizeView(selectedCrowd: $selectedCrowd, showCrowdSizeView: $showCrowdSizeView)
                        .padding(.trailing)
                }
                .transition(.move(edge: .trailing))
            }
        }
    }
}

#Preview("Bar Detail Popup") {
    HomeView()
        .overlay {
            BarDetailPopup(name: "Hideaway")
        }
}
