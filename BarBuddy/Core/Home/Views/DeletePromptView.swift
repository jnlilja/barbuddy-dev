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
        VStack {
            Text("Re-enter password to delete your account.")
                .font(.headline)
                .padding()
                .foregroundColor(.primary)
            
            ZStack {
                Rectangle()
                    .stroke(Color.primary, lineWidth: 1)
                    .frame(width: 300, height: 50)
                    .clipShape(.rect(cornerRadius: 8))
                
                
                SecureField("", text: $password, prompt: Text("Password").foregroundStyle(.darkPurple))
                    .textFieldStyle(CustomTextFieldStyle())
                    .foregroundStyle(.darkBlue)
                    .focused($isFocused)
                    .onSubmit {
                        Task {
                            do {
                                try await viewModel.reauthenticate(password: password)
                                actions.showDeleteAlert = false
                                actions.showDeleteConfirmationAlert = true
                            } catch {
                                actions.wrongPasswordAlertShown = true
                            }
                        }
                    }
            }
            HStack {
                Button {
                    withAnimation {
                        actions.showDeleteAlert = false
                    }
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
        .background()
        .clipShape(.rect(cornerRadius: 20))
        .shadow(radius: 5)
        .onDisappear {
            password = ""
        }
        .alert("Password is Incorrect", isPresented: $actions.wrongPasswordAlertShown) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your provided password did not match our records. Please try again.")
        }
    }
}

#Preview {
    @Previewable @State var password: String = ""
    @Previewable @State var actions = MainFeedActions()
    DeletePromptView(password: $password, actions: $actions)
        .environmentObject(AuthViewModel())
}
