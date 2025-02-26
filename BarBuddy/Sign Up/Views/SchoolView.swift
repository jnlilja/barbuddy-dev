//
//  SchoolView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct SchoolView: View {
    @State private var school = ""
    @State private var currentlyAttending = false
    @State private var major = ""
    @State private var showOnProfile = true
    @State private var proceedToNextPage = false
    
    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ProgressDots(currentPage: 4, totalPages: 7)
                
                VStack(spacing: 25) {
                    Text("Where did you go to school?")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    TextField("Enter your school", text: $school)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    Button(action: {
                        currentlyAttending.toggle()
                    }) {
                        HStack {
                            Image(systemName: currentlyAttending ? "checkmark.square.fill" : "square")
                                .foregroundColor(Color("Salmon"))
                                .font(.system(size: 20))
                            
                            Text("I currently attend this school")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    if currentlyAttending {
                        TextField("What's your major?", text: $major)
                            .textFieldStyle(CustomTextFieldStyle())
                            .transition(.opacity)
                    }
                    
                    Button(action: {
                        showOnProfile.toggle()
                    }) {
                        HStack {
                            Image(systemName: showOnProfile ? "checkmark.square.fill" : "square")
                                .foregroundColor(Color("Salmon"))
                                .font(.system(size: 20))
                            
                            Text("Show on my profile")
                                .foregroundColor(.white)
                        }
                    }
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
                    .disabled(school.isEmpty || (currentlyAttending && major.isEmpty))
                    .opacity(school.isEmpty || (currentlyAttending && major.isEmpty) ? 0.6 : 1)
                }
                
                Spacer()
            }
            .padding()
            .animation(.easeInOut, value: currentlyAttending)
        }
        .navigationBarHidden(true)
        
        NavigationLink(isActive: $proceedToNextPage) {
            DrinkPreferenceView()
        } label: {
            EmptyView()
        }
    }
}

#Preview("School") {
    SchoolView()
}
