//
//  SignUpView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import FirebaseAuth
import SwiftUI

struct SignUpView: View {
    @Environment(SignUpViewModel.self) private var viewModel
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var path: NavigationPath
    @FocusState private var focusedField: FocusField?
    @AppStorage("newUser") var newUser: Bool?

    enum FocusField {
        case email, password, confirmPassword
    }

    var body: some View {
        @Bindable var bindableViewModel = viewModel

        ZStack {
            AnimatedBackgroundView()

            VStack(spacing: 25) {
                Text("Create an Account")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 30)

                // ───────── Email
                TextField(
                    "",
                    text: $bindableViewModel.email,
                    prompt: Text("Email")
                        .foregroundStyle(
                            colorScheme == .dark ? .nude : Color(.systemGray)
                        )
                )
                .padding()
                .frame(width: 300, height: 50)
                .background(colorScheme == .dark ? .darkBlue : Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            viewModel.passwordsMatch
                            ? .darkPurple : .red,
                            lineWidth: 1
                        )
                )
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .focused($focusedField, equals: .email)
                .submitLabel(.next)

                // ───────── Password
                SecureField(
                    "",
                    text: $bindableViewModel.password,
                    prompt: Text("Password")
                        .foregroundStyle(
                            colorScheme == .dark ? .nude : Color(.systemGray)
                        )
                )
                .padding()
                .frame(width: 300, height: 50)
                .background(colorScheme == .dark ? .darkBlue : Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            viewModel.passwordsMatch
                                ? .darkPurple : .red,
                            lineWidth: 1
                        )
                )
                .focused($focusedField, equals: .password)
                .submitLabel(.next)

                // ───────── Confirm password
                SecureField(
                    "",
                    text: $bindableViewModel.confirmPassword,
                    prompt: Text("Confirm Password")
                        .foregroundStyle(
                            colorScheme == .dark ? .nude : Color(.systemGray)
                        )
                )
                .padding()
                .frame(width: 300, height: 50)
                .background(colorScheme == .dark ? .darkBlue : Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            viewModel.passwordsMatch
                                ? .darkPurple : .red,
                            lineWidth: 1
                        )
                )
                .focused($focusedField, equals: .confirmPassword)
                .submitLabel(.done)

                // validation hint
                if !viewModel.isValidPassword {
                    Text(
                        "Password must be at least 8 characters with a number and special character"
                    )
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                }

                // ───────── Sign‑up button
                Button {
                    guard viewModel.validate() else { return }
                    Task {
                        await authVM.signUp(
                            email: viewModel.email,
                            password: viewModel.password
                        )
                    }
                } label: {
                    Text("Sign Up")
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
                    guard viewModel.validate() else { return }
                    Task {
                        await authVM.signUp(
                            email: viewModel.email,
                            password: viewModel.password
                        )
                        if authVM.authUser != nil {
                            newUser = true
                        }
                    }
                }
            }
            .padding()
        }
        .alert("Validation Error", isPresented: $bindableViewModel.showingAlert)
        {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
        .alert("Authentication Error", isPresented: $authVM.showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authVM.getErrorMessage())
        }
    }
}
#Preview {
    @Previewable @State var signUpViewModel = SignUpViewModel()
    SignUpView(path: .constant(NavigationPath()))
        .environment(signUpViewModel)
        .environmentObject(AuthViewModel())
}
