import FirebaseAuth
import SwiftUI

struct SignUpView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject private var viewModel: SignUpViewModel
    @EnvironmentObject private var authVM: SessionManager

    var body: some View {
        ZStack {
            Color("DarkBlue").ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 30)

                // ───────── Email
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
                    .keyboardType(.emailAddress)

                // ───────── Username
                TextField("Username", text: $viewModel.newUsername)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)

                // ───────── Password
                SecureField("Password", text: $viewModel.newPassword)
                    .textFieldStyle(CustomTextFieldStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                viewModel.isValidPassword
                                    ? Color("DarkPurple") : .red,
                                lineWidth: 1
                            )
                    )

                // ───────── Confirm password
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
                    guard viewModel.runClientValidation() else { return }
                    let user = viewModel.buildProfile()
                    Task { await authVM.signUp(profile: user) }
                    //path.append(SignUpNavigation.ageVerification)
                } label: {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color("DarkPurple"))
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .alert("Sign‑Up Error", isPresented: $viewModel.showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}
#Preview {
    SignUpView(path: .constant(NavigationPath()))
        .environmentObject(SignUpViewModel())
}

// MARK: – View‑model helpers
extension SignUpViewModel {
    /// Runs client‑side validation; shows alerts; returns true when valid.
    fileprivate func runClientValidation() -> Bool {
        validateAndSignUp()
        return !showingAlert
    }
}
