//
//  NameEntryView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct NameEntryView: View {
    @Binding var path: NavigationPath
    @Environment(SignUpViewModel.self) var viewModel

    var body: some View {
        @Bindable var signUp = viewModel
        ZStack {
            Color("DarkBlue").ignoresSafeArea()

            VStack {
                Spacer()
                
                ProgressDots(currentPage: 0, totalPages: 7)
                
                VStack(spacing: 25) {
                    Text("What's Your Name?")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    TextField("First Name", text: $signUp.firstName)
                        .textFieldStyle(CustomTextFieldStyle())

                    TextField("Last Name", text: $signUp.lastName)
                        .textFieldStyle(CustomTextFieldStyle())

                    Button(action: {
                        // Navigate to the next step
                        path.append(SignUpNavigation.location)
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    .disabled(signUp.firstName.isEmpty || signUp.lastName.isEmpty)
                    .opacity(signUp.firstName.isEmpty || signUp.lastName.isEmpty ? 0.6 : 1) // Visual feedback for disabled state
                }

                Spacer()
            }
            .padding()
        }
    }
}

#Preview("Name") {
    NameEntryView(path: .constant(NavigationPath()))
        .environment(SignUpViewModel())
}
