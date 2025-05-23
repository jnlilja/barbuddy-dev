//
//  LoginView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/30/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email              = ""
    @State private var password           = ""
    @State private var showingSignUpSheet = false
    @State private var alertMessage       = ""
    @State private var showingAlert       = false
    
    @StateObject private var viewModel = SignUpViewModel()
    @State private var path = NavigationPath()
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var vm = LoginViewModel()       // pulls profile via /users

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                AnimatedBackgroundView()
                Circle().scale(1.7).foregroundColor(Color("Nude")).opacity(0.15)
                Circle().scale(1.35).foregroundColor(.nude).opacity(0.9)
                
                VStack(spacing: 15) {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color("DarkPurple"))
                        .padding(.bottom, 10)
                    
                    Text("BarBuddy")
                        .font(.largeTitle).bold()
                        .foregroundColor(Color("DarkPurple"))
                    
                    Text("Know Before You Go")
                        .font(.subheadline)
                        .foregroundColor(Color("DarkPurple"))
                        .padding(.bottom, 30)
                    
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("DarkPurple"), lineWidth: 1))
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("DarkPurple"), lineWidth: 1))
                        .padding(.top, 10)
                    
                    // ───────── Login button
                    Button {
                        Task {
                            await sessionManager.signIn(email: email, password: password)
                            // authVM.currentUser is now filled by AuthViewModel;
                            // dismiss or navigate to the main app UI here if you like.
                        }
                    } label: {
                        Text("Login")
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    .padding(.top, 25)
                    
                    Button("Don't have an account? Sign up") {
                        path.append(SignUpNavigation.createAccount)
                    }
                    .font(.subheadline)
                    .foregroundColor(Color("DarkPurple"))
                }
                
                if sessionManager.isLoading {
                    LoadingScreenView()
                        .navigationBarBackButtonHidden()
                        .transition(.blurReplace)
                }
            }
            //        .sheet(isPresented: $showingSignUpSheet) {
            //            SignUpView(isPresented: $showingSignUpSheet)
            //                .environmentObject(authVM)   // pass auth down
            //        }
            .navigationDestination(for: SignUpNavigation.self) { view in
                switch view {
                case .createAccount: SignUpView(path: $path)
//                case .ageVerification: AgeVerificationView(path: $path)
//                case .nameEntry: NameEntryView(path: $path)
//                case .location: LocationView(path: $path)
//                case .gender: GenderView(path: $path)
//                case .hometown: HometownView(path: $path)
//                case .school: SchoolView(path: $path)
//                case .drink: DrinkPreferenceView(path: $path)
//                case .photoPrompt: PhotoPromptView(path: $path)
//                case .photoUpload: PhotoUploadView()
                }
            }
            .alert("Login Error",
                   isPresented: $showingAlert,
                   actions: { Button("OK", role: .cancel) { } },
                   message: { Text(alertMessage) })
            .alert("Sign Up Error", isPresented: $sessionManager.showErrorAlert) {
                Button {
                    
                } label: {
                    Text("OK")
                }
            } message: {
                Text(sessionManager.errorMessage)
            }
        }
        .environmentObject(viewModel)
        .tint(.salmon)
    }

    // helper
    private func alert(_ msg: String) {
        alertMessage = msg
        showingAlert = true
    }
}

#Preview("Login View") {
    LoginView()
        .environmentObject(SignUpViewModel())
        .environmentObject(SessionManager())
}
