//
//  AgeVerificationView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

struct AgeVerificationView: View {
    @Environment(SignUpViewModel.self) var signUpViewModel
    @Binding var path: NavigationPath

    var body: some View {
        @Bindable var viewModel = signUpViewModel
        ZStack {
            Color(.darkBlue)
                .ignoresSafeArea()

            VStack(spacing: 25) {
                Text("Verify Your Age")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("You must be 21 or older to use BarBuddy")
                    .font(.title3)
                    .foregroundColor(.white)

                DatePicker(
                    "Date of Birth",
                    selection: $viewModel.birthday,
                    in: ...Date.now,
                    displayedComponents: .date
                )
                .padding()
                .background(Color(.secondarySystemGroupedBackground).opacity(0.9))
                .cornerRadius(10)
                .padding()

                Button(action: {
                    if viewModel.isOfAge() {
                        // format as ISO string
                        let fmt = DateFormatter()
                        fmt.dateFormat = "yyyy-MM-dd"
                        signUpViewModel.dateOfBirth = fmt.string(from: viewModel.birthday)
                        
                        //path.append(SignUpNavigation.nameEntry)
                    } else {
                        viewModel.showingAgeAlert = true
                    }
                }) {
                    Text("Verify Age")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                }
                .frame(width: 300, height: 50)
                .background(.darkPurple)
                .cornerRadius(10)
            }
            .padding()
        }
        .alert(
            "Age Verification Failed",
            isPresented: $viewModel.showingAgeAlert
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You must be 21 or older to use BarBuddy.")
        }
    }
}

#Preview {
    @Previewable @State var signUpViewModel = SignUpViewModel()
    AgeVerificationView(path: .constant(NavigationPath()))
        .environment(signUpViewModel)
}
