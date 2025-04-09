//
//  LoginView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/30/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var wrongUsername: Float = 0
    @State private var wrongPassword: Float = 0
    @State private var showingSignUpSheet = false
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            // Idea for new login page
            AnimatedBackgroundView()

            Circle()
                .scale(1.7)
                .foregroundColor(Color("Nude")).opacity(0.15)
            Circle()
                .scale(1.35)
                .foregroundColor(.nude).opacity(0.9)

            VStack {
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color("DarkPurple"))
                    .padding(.bottom, 20)

                Text("BarBuddy")
                    .font(.largeTitle)
                    .foregroundColor(Color("DarkPurple"))
                    .bold()

                Text("Know Before You Go")
                    .font(.subheadline)
                    .foregroundColor(Color("DarkPurple"))
                    .padding(.bottom, 50)

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("DarkPurple"), lineWidth: 1)
                    )
                    .border(.red, width: CGFloat(wrongUsername))

                SecureField("Password", text: $password)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("DarkPurple"), lineWidth: 1)
                    )
                    .border(.red, width: CGFloat(wrongPassword))
                    .padding(.top, 10)

                Button(action: {
                    Task {
                        try await authViewModel.signIn(
                                email: email, password: password)
                    }
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color("DarkPurple"))
                        .cornerRadius(10)
                }
                .padding(.top, 30)

                Button(action: {
                    showingSignUpSheet = true
                }) {
                    Text("Don't have an account? Sign up")
                        .font(.subheadline)
                        .foregroundColor(Color("DarkPurple"))
                }
                .padding(.top, 15)
            }
            .padding()
        }
        .sheet(isPresented: $showingSignUpSheet) {
            SignUpView(isPresented: $showingSignUpSheet)
        }
    }
}

#Preview("Login View") {
    LoginView()
        .environmentObject(AuthViewModel())
}
