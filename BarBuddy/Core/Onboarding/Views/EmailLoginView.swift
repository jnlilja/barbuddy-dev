//
//  LoginView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/30/25.
//

import SwiftUI
import FirebaseAuth

struct EmailLoginView: View {
    @State private var email              = ""
    @State private var password           = ""
    @State private var viewModel = SignUpViewModel()
    @Binding var path: NavigationPath
    @State private var isLoading = false
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var proceed: Bool
    
    @FocusState private var focusedField: FocusField?
    
    private enum FocusField {
        case email, password
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Button {
                    withAnimation {
                        proceed = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                        .padding([.leading, .top])
                }
                
                Spacer()
            }
            Spacer()
            
            VStack {
                Text("Welcome back to")
                    .font(.headline)
                    .foregroundStyle(colorScheme == .dark ? .white : .darkPurple)
                
                Text("BarBuddy")
                    .font(.system(size: 48)).bold()
                    .foregroundStyle(.darkBlue)
                    .padding(.bottom)
            }
            
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
            .disabled(isLoading)
            
            
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
            .disabled(isLoading)
            
            // ───────── Login button
            Button {

                withAnimation {
                    isLoading = true
                }
                    
                Task {
                    do {
                        try await authVM.signIn(email: email, password: password)
                    } catch {
                        
                    }
                }
            } label: {
                Text("Login")
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(colorScheme == .dark ? .salmon : .darkPurple)
                    .cornerRadius(10)
            }
            .padding(.top, 25)
            .disabled(isLoading)
            
            Spacer()
            
            Text("New to BarBuddy?")
                .fontWeight(.light)
                .foregroundStyle(.white)
            
            Button {
                path.append(SignUpNavigation.createAccount)
            } label: {
                Text("Create an account")
                    .underline()
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            
        }
        .onSubmit {
            if focusedField == .email {
                focusedField = .password
            } else {
                focusedField = nil

                withAnimation {
                    isLoading = true
                }
                
                Task {
                    do {
                        try await authVM.signIn(email: email, password: password)
                    } catch {
                        
                    }
                }
            }
        }
        .alert("Error signing in", isPresented: $authVM.showingAlert) {
            Button("OK", role: .cancel) {
                isLoading = false
            }
        } message: {
            Text(authVM.getErrorMessage())
        }
        .navigationDestination(for: SignUpNavigation.self) { view in
            Group {
                switch view {
                case .createAccount: SignUpView(path: $path)
                case .ageVerification: AgeVerificationView(path: $path)
                }
            }
            .environment(viewModel)
        }
        .tint(.salmon)
    }
}

#Preview("Login View") {
    @Previewable @State var proceed: Bool = false
    @Previewable @State var path = NavigationPath()
    ZStack {
        MeshGradientView()
        EmailLoginView(path: $path, proceed: $proceed)
            .environmentObject(AuthViewModel())
    }
}
