//
//  SwipeView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct SwipeView: View {
    @StateObject var viewModel = SwipeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("DarkBlue")
                    .ignoresSafeArea()
                
                VStack {
                    // Top Bar.
                    HStack {
                        HStack(spacing: 4) {
                            Text("@ Hideaway")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 4)
                                .background(Color("Salmon").opacity(0.3))
                                .cornerRadius(25)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        Spacer()
                    }
                    
                    // Card Stack.
                    ZStack {
                        if viewModel.users.isEmpty {
                            Text("No more users")
                                .font(.title)
                                .foregroundColor(.white)
                        } else {
                            ForEach(viewModel.users.reversed()) { user in
                                SwipeCard(user: user)
                                    .clipShape(RoundedRectangle(cornerRadius: 60))
                                    .overlay(
                                        HStack {
                                            // Left X Button.
                                            Button(action: {
                                                withAnimation {
                                                    viewModel.swipeLeft(user: user)
                                                }
                                            }) {
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 48, height: 48)
                                                    .shadow(radius: 5)
                                                    .overlay(
                                                        Image(systemName: "xmark")
                                                            .font(.system(size: 26))
                                                            .foregroundColor(.red)
                                                    )
                                            }
                                            .padding(.leading, 30)
                                            
                                            Spacer()
                                            
                                            // Right Heart Button.
                                            Button(action: {
                                                withAnimation {
                                                    viewModel.swipeRight(user: user)
                                                }
                                            }) {
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 48, height: 48)
                                                    .shadow(radius: 5)
                                                    .overlay(
                                                        Image(systemName: "heart.fill")
                                                            .font(.system(size: 26))
                                                            .foregroundColor(Color("Salmon"))
                                                    )
                                            }
                                            .padding(.trailing, 30)
                                        }
                                        // Position buttons slightly above the bottom.
                                        .offset(y: UIScreen.main.bounds.height * 0.085)
                                    )
                            }
                        }
                    }
                    .padding(.top, -20)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct SwipeView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeView()
    }
}
