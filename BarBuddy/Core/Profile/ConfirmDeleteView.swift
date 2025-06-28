//
//  ConfirmDeleteView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/26/25.
//

import SwiftUI

struct ConfirmDeleteView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State var promptPassword = false
    var body: some View {
        ZStack {
            Color.darkBlue
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.neonPink)
                
                Text("Delete BarBuddy Account?")
                    .padding(.top, 100)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("You will not be able to recover this account once it has been deleted.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .frame(width: 300, height: 40)

                Spacer()
                
                Button {
                    Task{
                        do {
                            let provider = viewModel.getCurrentProviderType()
                            switch provider {
                            case "apple.com":
                                break
                            case "google.com":
                                try await viewModel.reauthenticateWithGoogle()
                                try await viewModel.deleteUser()
                            default:
                                promptPassword = true
                            }
                        } catch {
                            print("Error reauthenticating: \(error)")
                        }
                    }
                } label: {
                    Text("Yes, I understand")
                        .foregroundStyle(.neonPink)
                        .frame(width: 200, height: 50)
                        .font(.callout)
                        .background(.white)
                        .clipShape(.rect(cornerRadius: 10))
                }

                Button { dismiss.callAsFunction() } label: {
                    Text("No, I changed my mind")
                        .foregroundStyle(.white)
                        .frame(width: 200, height: 50)
                        .font(.callout)
                        .background(.darkPurple)
                        .clipShape(.rect(cornerRadius: 10))
                        .padding(.vertical)
                }
            }
            .font(.largeTitle)
            .foregroundColor(.white)
            .bold()
            .sheet(isPresented: $promptPassword) {
                DeletePromptView()
                    .presentationDetents([.fraction(0.5)])
            }
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    ConfirmDeleteView()
        .environmentObject(AuthViewModel())
}
