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
    
    @State private var viewModel = SignUpViewModel()
    @State private var path = NavigationPath()
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @FocusState private var focusedField: FocusField?
    
    enum FocusField {
        case email, password
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Group {
                    AnimatedBackgroundView()
                    Circle().scale(1.7).foregroundColor(colorScheme == .dark ? .salmon : .nude).opacity(0.15)
                    Circle().scale(1.35).foregroundColor(colorScheme == .dark ? .darkBlue : .nude).opacity(0.9)
                }
                .onTapGesture {
                    // Hide keyboard when tapping outside of the input fields
                    focusedField = nil
                }
                
                VStack(spacing: 15) {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 60))
                        .foregroundColor(colorScheme == .dark ? .salmon : .darkPurple)
                        .padding(.bottom, 10)
                    
                    Text("BarBuddy")
                        .font(.largeTitle).bold()
                        .foregroundColor(colorScheme == .dark ? .salmon : .darkPurple)
                    
                    Text("Know Before You Go")
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .dark ? .nude : .darkPurple)
                        .padding(.bottom, 30)
                    
                    TextField("", text: $email, prompt: Text("Email")
                        .foregroundStyle(colorScheme == .dark ? .nude : Color(.systemGray))
                    )
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(colorScheme == .dark ? .darkBlue : .white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("DarkPurple"), lineWidth: 1))
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .textContentType(.emailAddress)
                        
                    
                    SecureField("Password", text: $password, prompt: Text("Password")
                        .foregroundStyle(colorScheme == .dark ? .nude : Color(.systemGray))
                    )
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(colorScheme == .dark ? .darkBlue : .white)
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
                            .background(colorScheme == .dark ? .salmon : .darkPurple)
                            .cornerRadius(10)
                    }
                    .padding(.top, 25)
                    
                    Button("Don't have an account? Sign up") {
                        path.append(SignUpNavigation.createAccount)
                    }
                    .font(.subheadline)
                    .foregroundColor(colorScheme == .dark ? .nude : .darkPurple)
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
            .alert("Error signing in", isPresented: $authVM.showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(authVM.getErrorMessage())
            }
            .navigationDestination(for: SignUpNavigation.self) { view in
                switch view {
                case .createAccount: SignUpView(path: $path).environment(viewModel)
                }
            }
            
        }
        .tint(.salmon)
    }
}

#Preview("Login View") {
    LoginView()
        .environmentObject(AuthViewModel())
}
