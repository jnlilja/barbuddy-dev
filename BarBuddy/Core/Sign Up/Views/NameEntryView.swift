//
//  NameEntryView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct NameEntryView: View {
    @State private var firstName = ""
    @State private var lastName  = ""
    @State private var proceedToLocation = false
    @Binding var path: NavigationPath
    @EnvironmentObject var viewModel: SignUpViewModel

    var body: some View {
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

                    TextField("First Name", text: $firstName)
                        .textFieldStyle(CustomTextFieldStyle())

                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(CustomTextFieldStyle())

                    Button(action: {
                        // Navigate to the next step
                        viewModel.firstName = firstName
                        viewModel.lastName = lastName
                        path.append(SignUpNavigation.location)
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                    .opacity(firstName.isEmpty || lastName.isEmpty ? 0.6 : 1) // Visual feedback for disabled state
                }

                Spacer()
            }
            .padding()
        }
    }
}

#Preview("Name") {
    NameEntryView(path: .constant(NavigationPath()))
        .environmentObject(SignUpViewModel())
}
