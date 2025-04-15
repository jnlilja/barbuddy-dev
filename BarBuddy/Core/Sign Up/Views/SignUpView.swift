//
//  SignUpView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//
import SwiftUI

struct SignUpView: View {
    @Environment(SignUpViewModel.self) var signUpViewModel
    @Binding var path: NavigationPath

    var body: some View {
        @Bindable var viewModel = signUpViewModel
        ZStack {
            Color(.darkBlue)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                    .padding(.bottom, 30)

                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(CustomTextFieldStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                viewModel.isValidEmail
                                    ? Color("DarkPurple") : .red,
                                lineWidth: 1
                            )
                    )
                    .autocapitalization(.none)

                TextField("Username", text: $viewModel.username)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(CustomTextFieldStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                viewModel.isValidPassword
                                    ? Color("DarkPurple") : .red,
                                lineWidth: 1
                            )
                    )

                SecureField(
                    "Confirm Password",
                    text: $viewModel.confirmPassword
                )
                .textFieldStyle(CustomTextFieldStyle())
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            viewModel.passwordsMatch
                                ? Color("DarkPurple") : .red,
                            lineWidth: 1
                        )
                )

                if !viewModel.isValidPassword {
                    Text(
                        "Password must be at least 8 characters with a number and special character"
                    )
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                }

                Button(action: {
                    viewModel.validateAndSignUp()
                    if viewModel.showingAgeVerification {
                        path.append(SignUpNavigation.ageVerification)
                    }
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color("DarkPurple"))
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .alert("Sign Up Error", isPresented: $viewModel.showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

#Preview {
    SignUpView(path: .constant(NavigationPath()))
        .environment(SignUpViewModel())
}
