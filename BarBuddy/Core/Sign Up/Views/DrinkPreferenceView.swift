//
//  DrinkPreferenceView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct DrinkPreferenceView: View {
    @State private var favoriteDrink = ""
    @State private var doesntDrink = false
    @State private var proceedToNextPage = false
    @Binding var path: NavigationPath
    
    var body: some View {
        
        ZStack {
            
            Color("DarkBlue")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ProgressDots(currentPage: 5, totalPages: 7)
                
                VStack(spacing: 25) {
                    Image(systemName: "cocktail")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    
                    Text("What's your drink of choice?")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    if !doesntDrink {
                        TextField("Enter your favorite drink", text: $favoriteDrink)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    Button(action: {
                        doesntDrink.toggle()
                        if doesntDrink {
                            favoriteDrink = "I don't drink"
                        } else {
                            favoriteDrink = ""
                        }
                    }) {
                        HStack {
                            Image(systemName: doesntDrink ? "checkmark.square.fill" : "square")
                                .foregroundColor(Color("Salmon"))
                                .font(.system(size: 20))
                            
                            Text("I don't drink 🙏")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        proceedToNextPage = true
                        path.append(NavigationDestinations.smoking)
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    .disabled(favoriteDrink.isEmpty)
                    .opacity(favoriteDrink.isEmpty ? 0.6 : 1)
                }
                
                Spacer()
            }
            .padding()
            .animation(.easeInOut, value: doesntDrink)
        }
    }
}


#Preview("Drinks") {
    DrinkPreferenceView(path: .constant(NavigationPath()))
}
