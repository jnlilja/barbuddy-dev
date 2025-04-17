//
//  AgeVerificationView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

struct AgeVerificationView: View {
    @State private var viewModel = AgeVerificationViewModel()
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @Binding var path: NavigationPath

    private var minimumDate: Date {
        Calendar.current.date(byAdding: .year, value: -120, to: Date())
            ?? Date()
    }

    private var maximumDate: Date {
        Date()
    }

    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()

            VStack(spacing: 25) {
                Text("Verify Your Age")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 50)

                Text("You must be 21 or older to use BarBuddy")
                    .font(.title3)
                    .foregroundColor(.white)

                DatePicker(
                    "",
                    selection: $viewModel.dateOfBirth,
                    in: minimumDate...maximumDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .background(Color.white.opacity(0.9))
                .cornerRadius(10)
                .padding()

                Button("Verify Age") {
                    // 1) run the check
                    viewModel.verifyAge()

                    // 2) if it passed, write back and navigate
                    if viewModel.proceedToName {
                        // format as ISO string
                        let fmt = DateFormatter()
                        fmt.dateFormat = "yyyy-MM-dd"
                        signUpViewModel.dateOfBirth = fmt.string(from: viewModel.dateOfBirth)
                        
                        path.append(SignUpNavigation.nameEntry)
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 300, height: 50)
                .background(Color("DarkPurple"))
                .cornerRadius(10)
            }
            .padding()
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
}

#Preview {
    AgeVerificationView(path: .constant(NavigationPath()))
        .environmentObject(SignUpViewModel())
}
