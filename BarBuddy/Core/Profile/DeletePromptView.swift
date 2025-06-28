//
//  DeletePromptView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/26/25.
//


import SwiftUI
import FirebaseAuth

struct DeletePromptView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @FocusState private var focusState: Focus?
    @State private var showAlert: Bool = false
    @State private var showPasswordError: Bool = false
    @State private var error: Error?
    
    enum Focus {
        case password, confirmPassword
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill()
                .ignoresSafeArea()
                .foregroundStyle(.darkBlue.gradient)
                
            VStack(alignment: .leading) {
                Text("Account Deletion")
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(.white)
                    .bold()
                
                Text("Enter your password to confirm deletion.")
                    .foregroundColor(.white)
                    .padding(.leading)
                
                SecureField(
                    "",
                    text: $password
                )
                .padding(.leading, 10)
                .textFieldStyle(.plain)
                .foregroundStyle(.primary)
                .frame(width: 300, height: 34)
                .focused($focusState, equals: .password)
                .background(.white)
                .clipShape(.rect(cornerRadius: 10))
                .padding(.leading)
                
                Text("Re-enter your password.")
                    .foregroundColor(.white)
                    .padding([.leading, .top])
                
                SecureField(
                    "",
                    text: $confirmPassword,
                )
                .padding(.leading, 10)
                .textFieldStyle(.plain)
                .foregroundStyle(.primary)
                .frame(width: 300, height: 34)
                .focused($focusState, equals: .confirmPassword)
                .background(.white)
                .clipShape(.rect(cornerRadius: 10))
                .padding(.leading)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button {
                        Task {
                            do {
                                try await viewModel.reauthenticate(password: password)
                                showAlert = true
                            } catch {
                                showPasswordError = true
                                self.error = error
                            }
                        }
                    } label: {
                        HStack {
                            Text("Confirm")
                                .frame(width: 100, height: 45)
                                .bold()
                                .foregroundColor(colorScheme == .dark ? .darkBlue : .white)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(colorScheme == .dark ? .nude : Color.darkPurple)
                                )
                                .padding(.bottom)
                        }
                    }
                    Spacer()
                }
                .padding(.top)
            }
        }
        .tint(.salmon)
        .alert("Something Went Wrong", isPresented: $showPasswordError) {
            Button("OK") {}
        } message: {
            if error is APIError {
                Text("You are currently not signed in.")
            } else if let error = error as? NSError, error.domain == AuthErrorDomain {
                switch AuthErrorCode(rawValue: error.code) {
                case .wrongPassword:
                    Text("Incorrect password.")
                case .networkError:
                    Text("Network Error. Please try again later.")
                default:
                    Text(error.localizedDescription)
                }
            }
        }
        .alert("Warning", isPresented: $showAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteUser(password: password)
                    } catch {
                        
                    }
                }
            }
        } message: {
            Text("This action cannot be undone. Your account will be permanently deleted.")
        }
        .tint(.darkBlue)
        .onSubmit {
            if focusState == .password {
                focusState = .confirmPassword
                return
            } else {
                Task {
                    do {
                        try await viewModel.reauthenticate(password: password)
                        showAlert = true
                    } catch let error {
                        showPasswordError = true
                        self.error = error
                    }
                }
            }
        }
    }
}

#Preview {
    DeletePromptView()
        .environmentObject(AuthViewModel())
}
