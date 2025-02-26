//
//  SmokingPreferenceView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct SmokingPreferenceView: View {
    @State private var smokesWeed = false
    @State private var smokesTobacco = false
    @State private var vapes = false
    @State private var proceedToNextPage = false
    
    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ProgressDots(currentPage: 6, totalPages: 7)
                
                VStack(spacing: 25) {
                    Text("Do you smoke?")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 20) {
                        Button(action: {
                            smokesWeed.toggle()
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: smokesWeed ? "checkmark.square.fill" : "square")
                                    .foregroundColor(Color("Salmon"))
                                    .font(.system(size: 20))
                                
                                Text("Cannabis 🍃")
                                    .foregroundColor(.white)
                                    .font(.title3)
                            }
                        }
                        .frame(width: 200)
                        
                        Button(action: {
                            smokesTobacco.toggle()
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: smokesTobacco ? "checkmark.square.fill" : "square")
                                    .foregroundColor(Color("Salmon"))
                                    .font(.system(size: 20))
                                
                                Text("Cigarettes 🚬")
                                    .foregroundColor(.white)
                                    .font(.title3)
                            }
                        }
                        .frame(width: 200)
                        
                        Button(action: {
                            vapes.toggle()
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: vapes ? "checkmark.square.fill" : "square")
                                    .foregroundColor(Color("Salmon"))
                                    .font(.system(size: 20))
                                
                                Text("Vape 💨")
                                    .foregroundColor(.white)
                                    .font(.title3)
                            }
                        }
                        .frame(width: 200)
                    }
                    .padding(.vertical, 30)
                    
                    Button(action: {
                        proceedToNextPage = true
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
        
        NavigationLink(isActive: $proceedToNextPage) {
            PhotoPromptView()
        } label: {
            EmptyView()
        }
    }
}

#Preview("Smoking") {
    SmokingPreferenceView()
}
