//
//  SignUpView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import FirebaseAuth
import SwiftUI

struct SignUpView: View {
    @Environment(SignUpViewModel.self) var viewModel
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var path: NavigationPath
    @FocusState private var focusedField: FocusField?
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        GeometryReader { proxy in
            ZStack {
                Color.darkBlue.ignoresSafeArea()
                VStack(spacing: 25) {
                    VStack {
                        Text("Let's get started!")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                    }
                    
                    // Email
                    SignUpTextFieldView(prompt: "Email", text: $viewModel.email, geometry: proxy)
                        .focused($focusedField, equals: .email)
                    
                    // Name
                    SignUpTextFieldView(prompt: "First Name", text: $viewModel.firstName, geometry: proxy)
                        .focused($focusedField, equals: .email)
                    
                    SignUpTextFieldView(prompt: "Last Name", text: $viewModel.lastName, geometry: proxy)
                        .focused($focusedField, equals: .email)
                        
                    // Password
                    SignUpTextFieldView(prompt: "Password", text: $viewModel.password, geometry: proxy, isPassword: true)
                        .focused($focusedField, equals: .password)
                    
                    // Confirm Password
                    SignUpTextFieldView(prompt: "Confirm Password", text: $viewModel.confirmPassword, geometry: proxy, isPassword: true)
                        .focused($focusedField, equals: .confirmPassword)
                    
                    Text(
                        "Password must be at least 8 characters with a number and special character"
                    )
                    .font(.caption)
                    .foregroundColor(.neonPink)
                    .multilineTextAlignment(.center)
                    .opacity(!viewModel.isValidPassword ? 1 : 0)
                    
                    Spacer()
                    
                    // ───────── Sign‑up button
                    Button {
                        guard viewModel.validate() else { return }
                        path.append(SignUpNavigation.ageVerification)
                        
                    } label: {
                        Text("Continue")
                            .foregroundColor(colorScheme == .dark ? .darkPurple : .white)
                            .frame(width: 300, height: 50)
                            .background(colorScheme == .dark ? .nude : .darkPurple)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
                .onSubmit {
                    if focusedField == .email {
                        focusedField = .password
                    } else if focusedField == .password {
                        focusedField = .confirmPassword
                    } else {
                        focusedField = nil
                        guard viewModel.validate() else {
                            return
                        }
                        path.append(SignUpNavigation.ageVerification)
                    }
                }
                .padding()
                
                .alert("Validation Error", isPresented: $viewModel.showingAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(viewModel.alertMessage)
                }
                .alert("Failed to Sign Up", isPresented: $authVM.signUpAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(authVM.getErrorMessage())
                }
            }
        }
    }
}
#Preview {
    @Previewable @State var signUpViewModel = SignUpViewModel()
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path) {
        SignUpView(path: $path)
            .environment(signUpViewModel)
            .environmentObject(AuthViewModel())
    }
}
