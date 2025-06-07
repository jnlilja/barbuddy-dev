//
//  VoteBoxView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/21/25.
//

import SwiftUI

struct VoteSelectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var properties: ButtonProperties
    @Binding var bar: Bar
    @State private var selectedOption: String?
    
    var body: some View {
        VStack {
            Spacer()
            Text("How long is the wait?")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .salmon : .darkBlue)
                .padding(.top)
            
            Text("Select a time below")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white :.darkPurple)
                .padding(.bottom, 20)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 70, maximum: 120), spacing: 15),
                GridItem(.adaptive(minimum: 70, maximum: 120), spacing: 15),
                GridItem(.adaptive(minimum: 70, maximum: 120))
            ]) {
                
                VoteButtonView(text: "<5 min", opacity: 0.15, properties: $properties, selectedOption: $selectedOption)
                VoteButtonView(text: "5-10 min", opacity: 0.2, properties: $properties, selectedOption: $selectedOption)
                VoteButtonView(text: "10-20 min", opacity: 0.3, properties: $properties, selectedOption: $selectedOption)
                VoteButtonView(text: "20-30 min", opacity: 0.4, properties: $properties, selectedOption: $selectedOption)
                VoteButtonView(text: ">30 min", opacity: 0.5, properties: $properties, selectedOption: $selectedOption)
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
                    .background(colorScheme == .dark
                                ? .nude : .salmon.opacity(0.2))
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
                                    // Submit wait time
                                    try await BarNetworkManager.shared.submitVote(
                                        vote: BarVote(
                                            bar: bar.id,
                                            waitTime: vote)
                                    )
                                    print("Vote submitted successfully for bar \(bar.id) with wait time: \(vote)")
                                    
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
                            .background(
                                colorScheme == .dark
                                    ? Gradient(colors: [.darkPurple, .salmon])
                                    : Gradient(colors: [.darkBlue, .darkPurple])
                            )
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
    VoteSelectionView(properties: .constant(.init(didSubmit: false, showMenu: false, type: "wait")), bar: .constant(Bar.sampleBar))
}
