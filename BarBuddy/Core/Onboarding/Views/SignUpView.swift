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
    @State private var isLoading: Bool = false
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        ZStack {
            Color.darkBlue
                .ignoresSafeArea()
                .onTapGesture {
                    focusedField = nil
                }
            GeometryReader { proxy in
                VStack(spacing: 25) {
                    
                    Spacer()
                    
                    Text("Let's get started!")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                    
                    // Email
                    SignUpTextFieldView(prompt: "Email", text: $viewModel.email, geometry: proxy)
                        .focused($focusedField, equals: .email)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .submitLabel(.next)
                    
                    // Password
                    SignUpTextFieldView(prompt: "Password", text: $viewModel.password, geometry: proxy, isPassword: true)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.next)
                    
                    // Confirm Password
                    SignUpTextFieldView(prompt: "Confirm Password", text: $viewModel.confirmPassword, geometry: proxy, isPassword: true)
                        .focused($focusedField, equals: .confirmPassword)
                        .submitLabel(.done)
                    
                    // ───────── Sign‑up button
                    Button {
                        focusedField = nil
                        withAnimation {
                            isLoading = true
                        }
                        guard viewModel.validate() else {
                            isLoading = false
                            return
                        }
                        //path.append(SignUpNavigation.ageVerification)
                        Task {
                            await authVM.signUp(email: viewModel.email, password: viewModel.password)
                            
                            if authVM.signUpAlert || viewModel.showingAgeAlert {
                                isLoading = false
                            }
                        }
                    } label: {
                        Text("Continue")
                            .foregroundColor(colorScheme == .dark ? .darkPurple : .white)
                            .frame(width: 300, height: 50)
                            .background(colorScheme == .dark ? .nude : .darkPurple)
                            .cornerRadius(10)
                            .padding(.top, 30)
                    }
                    
                    Spacer()
                }
                .onSubmit {
                    if focusedField == .email {
                        focusedField = .password
                    } else if focusedField == .password {
                        focusedField = .confirmPassword
                    } else {
                        withAnimation {
                            isLoading = true
                        }
                        focusedField = nil
                        guard viewModel.validate() else {
                            isLoading = false
                            return
                        }
                        //path.append(SignUpNavigation.ageVerification)
                        Task {
                            await authVM.signUp(email: viewModel.email, password: viewModel.password)
                            
                            if authVM.signUpAlert || viewModel.showingAgeAlert {
                                isLoading = false
                            }
                        }
                    }
                }
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
                .overlay {
                    if isLoading {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 100, height: 100)
                                .foregroundStyle(Color(.secondarySystemGroupedBackground))
                                .shadow(radius: 5)
                            
                            ProgressView()
                                .tint(.salmon)
                        }
                        .transition(.scale)
                    }
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
