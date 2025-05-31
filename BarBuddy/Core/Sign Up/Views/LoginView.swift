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
    @State private var alertMessage       = ""
    
    @StateObject private var viewModel = SignUpViewModel()
    @State private var path = NavigationPath()
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = LoginViewModel()
    
    @FocusState private var focusedField: FocusField?
    
    enum FocusField {
        case email, password
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                AnimatedBackgroundView()
                Circle().scale(1.7).foregroundColor(.nude).opacity(0.15)
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
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .textContentType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("DarkPurple"), lineWidth: 1))
                        .padding(.top, 10)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)
                        .textContentType(.password)
                    
                    // ───────── Login button
                    Button {
                        Task {
                            await authVM.signIn(email: email, password: password)
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
            }
            .onSubmit {
                if focusedField == .email {
                    focusedField = .password
                } else {
                    focusedField = nil
                    Task { await authVM.signIn(email: email, password: password) }
                }
            }
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
        }
        .environmentObject(viewModel)
        .tint(.salmon)
    }
}

#Preview("Login View") {
    LoginView()
        .environmentObject(SignUpViewModel())
        .environmentObject(AuthViewModel())
}
