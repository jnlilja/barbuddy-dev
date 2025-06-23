//
//  DeletePromptView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/21/25.
//

import SwiftUI

struct DeletePromptView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var password: String
    @FocusState var isFocused: Bool
    @Binding var actions: MainFeedActions
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { isFocused = false }
                
            VStack {
                Text("Re-enter password to delete your account.")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                SecureField(
                    "",
                    text: $password,
                    prompt: Text("Password")
                        .foregroundStyle(colorScheme == .dark ? .white : .darkBlue)
                )
                .textFieldStyle(.roundedBorder)
                .foregroundStyle(.primary)
                .frame(width: 300, height: 50)
                .focused($isFocused)
                .onSubmit {
                    Task {
                        do {
                            try await viewModel.reauthenticate(password: password)
                            actions.showDeleteAlert = false
                            actions.showDeleteConfirmationAlert = true
                        } catch {
                            print("Error reauthenticating: \(error.localizedDescription)")
                            actions.wrongPasswordAlertShown = true
                        }
                    }
                }
                HStack {
                    Button {
                        withAnimation {
                            actions.showDeleteAlert = false
                        }
                        password = ""
                    } label: {
                        Text("Cancel")
                            .frame(width: 100, height: 45)
                            .bold()
                            .foregroundColor(colorScheme == .dark ? .darkBlue : .white)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(colorScheme == .dark ? .nude : Color.darkBlue)
                            )
                            .padding(.trailing, 20)
                    }
                    
                    Button {
                        Task {
                            do {
                                try await viewModel.reauthenticate(password: password)
                                actions.showDeleteAlert = false
                                actions.showDeleteConfirmationAlert = true
                            } catch {
                                print("Error reauthenticating: \(error.localizedDescription)")
                                actions.wrongPasswordAlertShown = true
                            }
                        }
                    } label: {
                        Text("Confirm")
                            .frame(width: 100, height: 45)
                            .bold()
                            .foregroundColor(colorScheme == .dark ? .darkBlue : .white)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(colorScheme == .dark ? .nude : Color.darkBlue)
                            )
                    }
                }
                .padding()
            }
            .padding()
            .background(Color(.tertiarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 20))
            .shadow(radius: 5)
            .alert("Password is Incorrect", isPresented: $actions.wrongPasswordAlertShown) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your provided password did not match our records. Please try again.")
            }
            .transition(.opacity)
        }
    }
}

#Preview {
    @Previewable @State var password: String = ""
    @Previewable @State var actions = MainFeedActions()
    DeletePromptView(password: $password, actions: $actions)
        .environmentObject(AuthViewModel())
}
