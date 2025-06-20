//
//  WelcomeView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/19/25.
//

import SwiftUI

struct WelcomeView: View {
    @State private var proceed = false
    var body: some View {
        if !proceed {
            ZStack {
                AnimatedBackgroundView()
                
                VStack {
                    Spacer()
                    
                    Image("Icon-Dark-1024x1024-3")
                        .resizable()
                        .scaledToFit()
                    
                    Spacer()
                    
                    Text("Track wait times at your favorite bars in Pacific Beach!")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .fontDesign(.rounded)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        withAnimation {
                            proceed = true
                        }
                    } label: {
                        Text("Continue to sign-in")
                            .bold()
                            .padding()
                            .background(.salmon.gradient)
                            .clipShape(.rect(cornerRadius: 20))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .padding(.bottom)
                    }
                }
            }
        } else {
            LoginView()
                .transition(.opacity)
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthViewModel())
}
