//
//  ContentView.swift
//  BarBuddy
//
//  Created by Jessica Lilja on 2/5/25.
//

import SwiftUI

struct ContentView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var wrongUsername: Float = 0
    @State private var wrongPassword: Float = 0
    @State private var showingLoginScreen = false
    @State private var showingSignUpSheet = false
    @StateObject private var creteUserViewModel = SignUpViewModel()

    // Skip the login/sign up views when set to true
    private let skipToHome = true

    var body: some View {
        if !skipToHome {
            NavigationStack {
                ZStack {
                    Color("DarkBlue")
                        .ignoresSafeArea()
                    Circle()
                        .scale(1.7)
                        .foregroundColor(Color("Nude")).opacity(0.15)
                    Circle()
                        .scale(1.35)
                        .foregroundColor(.white).opacity(0.9)

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

                        TextField("Username", text: $username)
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
                            authenticateUser(
                                username: username, password: password)
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
                .navigationDestination(isPresented: $showingLoginScreen) {
                    Text("You are logged in, \(username)")
                }
                .sheet(isPresented: $showingSignUpSheet) {
                    SignUpView(isPresented: $showingSignUpSheet)
                        .environmentObject(creteUserViewModel)
                }
            }
        } else {
            HomeView()
        }
    }

    func authenticateUser(username: String, password: String) {
        if username.lowercased() == "mario2021" {
            wrongUsername = 0
            if password.lowercased() == "abc123" {
                wrongPassword = 0
                showingLoginScreen = true
            } else {
                wrongPassword = 2
            }
        } else {
            wrongUsername = 2
        }
    }
}

// Login Flow Preview
#Preview("Login") {
    ContentView()
        .environmentObject(MapViewModel())
}
