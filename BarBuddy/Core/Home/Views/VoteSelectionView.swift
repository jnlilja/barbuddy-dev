//
//  VoteBoxView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/21/25.
//

import SwiftUI

struct VoteSelectionView: View {
    @Binding var properties: ButtonProperties
    @Binding var bar: Bar
    @State private var selectedOption: String?
    @Environment(VoteViewModel.self) var voteViewModel
    
    var body: some View {
        VStack {
            Spacer()
            Text("How long is the wait?")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.darkBlue)
                .padding(.top)
            
            Text("Select a time below")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.darkPurple)
                .padding(.bottom, 20)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 70, maximum: 150), spacing: 5),
                GridItem(.adaptive(minimum: 70, maximum: 150), spacing: 5),
                GridItem(.adaptive(minimum: 70, maximum: 150))
            ]) {
                
                VoteBoxButtonView(text: "< 5 min", opacity: 0.06, properties: $properties, bar: $bar, selectedOption: $selectedOption)
                VoteBoxButtonView(text: "5 - 10 min", opacity: 0.1, properties: $properties, bar: $bar, selectedOption: $selectedOption)
                VoteBoxButtonView(text: "10 - 20 min", opacity: 0.2, properties: $properties, bar: $bar, selectedOption: $selectedOption)
                VoteBoxButtonView(text: "20 - 30 min", opacity: 0.3, properties: $properties, bar: $bar, selectedOption: $selectedOption)
                VoteBoxButtonView(text: "30 - 45 min", opacity: 0.4, properties: $properties, bar: $bar, selectedOption: $selectedOption)
                VoteBoxButtonView(text: "> 45 min", opacity: 0.5, properties: $properties, bar: $bar, selectedOption: $selectedOption)
            }
            .padding(.horizontal)
            
            Spacer()
            
            HStack {
                Button {
                    withAnimation {
                        properties.showMenu = false
                    }
                } label: {
                    HStack {
                        Text("Cancel")
                            .foregroundColor(Color("DarkPurple"))
                        Image(systemName: "xmark")
                            .foregroundColor(Color("DarkPurple"))
                    }
                    .frame(width: 200)
                    .padding()
                    .background(Color("Salmon").opacity(0.2))
                    .foregroundColor(Color("DarkPurple"))
                    .cornerRadius(15)
                    .padding(.bottom, 30)
                }
                
                if selectedOption != nil {
                    Button {
                        withAnimation {
                            properties.didSubmit = true
                        }
                        if let vote = selectedOption {
                            Task {
                                do {
                                    if let id = bar.id {
                                        // Submit wait time
                                        try await BarNetworkManager.shared.submitVote(
                                            vote: BarVote(
                                                bar: id,
                                                waitTime: vote,
                                                timeStamp: DateFormatter.formatTimeStamp(Date())
                                            )
                                        )
                                        print("Vote submitted successfully for bar \(id) with wait time: \(vote)")
                                    }
                                } catch {
                                    print("Failed to submit vote: \(error)")
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation {
                                    properties.didSubmit = false
                                    properties.showMenu = false
                                }
                            }
                        }
                    } label: {
                        Text("Submit Vote")
                            .frame(width: 100)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .padding()
                            .background(Gradient(colors: [.darkBlue, .darkPurple]))
                            .foregroundColor(.nude)
                            .cornerRadius(15)
                            .padding(.bottom, 30)
                    }
                    .padding(.leading, 10)
                }
            }
        }
    }
}

#Preview {
    VoteSelectionView(properties: .constant(.init(didSubmit: false, showMenu: false, type: "wait")), bar: .constant(Bar(id: 1, name: "Test Bar", address: "123 Test St", averagePrice: "10", latitude: 37.774722, longitude: -122.418233, location: nil, usersAtBar: 10, currentStatus: nil, averageRating: "4.5", images: nil, currentUserCount: nil, activityLevel: nil)))
        .environment(VoteViewModel())
}
