//
//  WelcomeView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/19/25.
//

import SwiftUI
import AuthenticationServices

struct WelcomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var proceedToEmail = false
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                MeshGradientView()
                
                if !proceedToEmail {
                    VStack {
                        
                        Spacer()
                        
                        Image(colorScheme == .dark ? "Beer-logo-dark" : "Beer-logo-light")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                        
                        Text("BarBuddy")
                            .font(.system(size: 48, weight: .bold, design: .default))
                            .foregroundColor(.darkBlue)
                            .multilineTextAlignment(.center)
                        
                        Text("Know Before You Go")
                            .foregroundStyle(.darkBlue)
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                proceedToEmail = true
                            }
                        } label: {
                            Image(systemName: "envelope.fill")
                            Text("Sign in with Email")
                        }
                        .bold()
                        .frame(width: 330, height: 50)
                        .background(.darkPurple.gradient)
                        .clipShape(.rect(cornerRadius: 20))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.bottom)
                        
                        Button {
                            Task {
                                do {
                                    try await authViewModel.signInWithGoogle()
                                } catch {
                                    
                                }
                            }
                        } label: {
                            Image("google")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                            
                            Text("Sign in with Google")
                                .bold()
                            
                        }
                        .frame(width: 330, height: 50)
                        .background(.white.gradient)
                        .clipShape(.rect(cornerRadius: 20))
                        .foregroundColor(.black)
                        .shadow(radius: 5)
                        .padding(.bottom)
                        
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.email, .fullName]
                            let hashedNonce = authViewModel.prepareAppleSignIn()
                            request.nonce = hashedNonce
                            
#if DEBUG
                            print("🍎 Apple Sign In: Request prepared with nonce")
#endif
                            
                        } onCompletion: { result in
#if DEBUG
                            print("🍎 Apple Sign In: Completion handler called")
#endif
                            
                            switch result {
                            case .success(let authorization):
#if DEBUG
                                print("🍎 Apple Sign In: Authorization successful")
#endif
                                
                                Task {
                                    await authViewModel.signInWithApple(authorization)
                                }
                                if let userCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                                    // Email and name are only provided on first sign-in, not subsequent ones
                                    if let email = userCredential.email {
                                        print("📧 Apple provided email: \(email)")
                                    } else {
                                        print("📧 No email provided (likely returning user)")
                                    }
                                    if let firstName = userCredential.fullName?.givenName,
                                       let lastName = userCredential.fullName?.familyName {
                                        print("👤 Apple provided name: \(firstName) \(lastName)")
                                    } else {
                                        print("👤 No name provided (likely returning user)")
                                    }
                                }
                            case .failure(let error):
#if DEBUG
                                print("❌ Apple Sign In: Authorization failed")
                                print("   Error: \(error)")
                                print("   Localized: \(error.localizedDescription)")
#endif
                                
                                let authError = error as? ASAuthorizationError
                                switch authError?.code {
                                case .canceled:
                                    print("👤 User canceled Apple Sign In")
                                    // Don't show an error for user cancellation
                                case .failed:
                                    print("❌ Apple Sign In failed")
                                case .invalidResponse:
                                    print("❌ Apple Sign In invalid response")
                                case .notHandled:
                                    print("❌ Apple Sign In not handled")
                                case .unknown:
                                    print("❌ Apple Sign In unknown error")
                                default:
                                    print("❌ Apple Sign In unhandled error: \(error.localizedDescription)")
                                }
                            }
                        }
                        .frame(width: 330, height: 50)
                        .clipShape(.rect(cornerRadius: 20))
                        .padding(.horizontal, 40)
                        .shadow(radius: 5)
                        .padding(.bottom)
                        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                        
                        Button {
                            Task {
                                await authViewModel.anonymousLogin()
                            }
                        } label: {
                            Text("Continue as Guest")
                                .foregroundStyle(.white)
                                .underline()
                        }
                    }
                    .transition(.blurReplace)
                    
                } else {
                    EmailLoginView(path: $path, proceed: $proceedToEmail)
                        .transition(.blurReplace)
                }
            }
        }
        .tint(.salmon)
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthViewModel())
}
