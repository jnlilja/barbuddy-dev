//
//  GenderView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct GenderView: View {
    @State private var selectedGender: String?
    @State private var proceedToNextPage = false
    
    let genderOptions = ["Man", "Woman", "Non-binary", "Prefer not to say"]
    
    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ProgressDots(currentPage: 2, totalPages: 7)
                
                VStack(spacing: 25) {
                    Text("What's your gender?")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 15) {
                        ForEach(genderOptions, id: \.self) { gender in
                            Button(action: {
                                selectedGender = gender
                            }) {
                                Text(gender)
                                    .bold()
                                    .frame(width: 300, height: 50)
                                    .background(selectedGender == gender ? Color("DarkPurple") : Color("Salmon"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    Text("BarBuddy is for making friends! You'll see both men and women in your area, but you can adjust your preferences later.")
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
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
                    .disabled(selectedGender == nil)
                    .opacity(selectedGender == nil ? 0.6 : 1)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
        
        NavigationLink(isActive: $proceedToNextPage) {
            HometownView()
        } label: {
            EmptyView()
        }
    }
}

#Preview("Gender") {
    GenderView()
}
