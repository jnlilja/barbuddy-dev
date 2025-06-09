//
//  SignUpView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @Environment(SignUpViewModel.self) private var viewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var path: NavigationPath
    @FocusState private var focusedField: FocusField?
    
    enum FocusField {
        case email, password, confirmPassword
    }

    var body: some View {
        @Bindable var bindableViewModel = viewModel
        
        ZStack {
            Color("DarkBlue").ignoresSafeArea()

            VStack(spacing: 25) {
                Text("Create an Account")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 30)

                // ───────── Email
                TextField("Email", text: $bindableViewModel.email)
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
                    .keyboardType(.emailAddress)
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)

                // ───────── Password
                SecureField("Password", text: $bindableViewModel.password)
                    .textFieldStyle(CustomTextFieldStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                viewModel.isValidPassword
                                    ? Color("DarkPurple") : .red,
                                lineWidth: 1
                            )
                    )
                    .focused($focusedField, equals: .password)
                    .submitLabel(.next)

                // ───────── Confirm password
                SecureField(
                    "Confirm Password",
                    text: $bindableViewModel.confirmPassword
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
                    Task { await authVM.signUp(email: viewModel.email, password: viewModel.password) }
                } label: {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color("DarkPurple"))
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
                    Task { await authVM.signUp(email: viewModel.email, password: viewModel.password) }
                }
            }
            .padding()
        }
        .alert("Validation Error", isPresented: $bindableViewModel.showingAlert) {
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
