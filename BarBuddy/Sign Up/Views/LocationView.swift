//
//  LocationView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct LocationView: View {
    @Binding var path: NavigationPath
    @State private var proceedToProfileSetup = false
    
    var body: some View {
        
            ZStack {
                Color("DarkBlue")
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    ProgressDots(currentPage: 1, totalPages: 7)
                    
                    VStack(spacing: 25) {
                        Text("Where are you located?")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Beta Version: Currently available for Pacific Beach, San Diego select bars only")
                            .font(.headline)
                            .foregroundColor(Color("Salmon"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("We're starting small to ensure the best experience! More locations coming soon.")
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            proceedToProfileSetup = true
                            path.append(NavigationDestinations.gender)
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
        }
    }


#Preview("Location") {
    LocationView(path: .constant(NavigationPath()))
}
