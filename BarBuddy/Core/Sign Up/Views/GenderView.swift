//
//  GenderView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

struct GenderView: View {
    @State private var proceedToNextPage = false
    @Binding var path: NavigationPath

    // ← use EnvironmentObject for your ObservableObject view‑model
    @EnvironmentObject var viewModel: SignUpViewModel

    let genderOptions = ["Man", "Woman", "Non‑binary", "Prefer not to say"]

    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()

            VStack {
                Spacer()

                ProgressDots(currentPage: 2, totalPages: 7)

                VStack(spacing: 25) {
                    Text("What's your gender?")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    VStack(spacing: 15) {
                        ForEach(genderOptions, id: \.self) { gender in
                            Button {
                                viewModel.gender = gender
                            } label: {
                                Text(gender)
                                    .bold()
                                    .frame(width: 300, height: 50)
                                    .background(
                                      viewModel.gender == gender
                                        ? Color("DarkPurple")
                                        : Color("Salmon")
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.vertical)

                    Text("BarBuddy is for making friends! You’ll see both men and women in your area, but you can adjust your preferences later.")
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button {
                        proceedToNextPage = true
                        path.append(SignUpNavigation.hometown)
                    } label: {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    .disabled(viewModel.gender.isEmpty)
                    .opacity(viewModel.gender.isEmpty ? 0.6 : 1)
                }

                Spacer()
            }
            .padding()
        }
    }
}

#Preview("Gender") {
    GenderView(path: .constant(NavigationPath()))
      // ← inject the shared SignUpViewModel here
      .environmentObject(SignUpViewModel())
}
