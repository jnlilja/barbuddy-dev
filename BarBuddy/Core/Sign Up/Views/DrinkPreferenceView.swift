//
//  DrinkPreferenceView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct DrinkPreferenceView: View {
    @Binding var path: NavigationPath
    @Environment(SignUpViewModel.self) var viewModel

    var body: some View {
        @Bindable var signUp = viewModel
        ZStack {
            Color("DarkBlue").ignoresSafeArea()

            VStack {
                Spacer()

                ProgressDots(currentPage: 5, totalPages: 7)

                VStack(spacing: 25) {
                    Image(systemName: "cocktail")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)

                    Text("What's your drink of choice?")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    if !viewModel.doesntDrink {
                        TextField("Enter your favorite drink", text: $signUp.favoriteDrink)
                            .textFieldStyle(CustomTextFieldStyle())
                    }

                    Button {
                        viewModel.doesntDrink.toggle()
                        if viewModel.doesntDrink {
                            signUp.favoriteDrink = "I don't drink"
                        } else {
                            signUp.favoriteDrink = ""
                        }
                    } label: {
                        HStack {
                            Image(systemName: viewModel.doesntDrink ? "checkmark.square.fill" : "square")
                                .foregroundColor(Color("Salmon"))
                                .font(.system(size: 20))
                            Text("I don't drink 🙏")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)

                    Button(action: {
                        path.append(SignUpNavigation.photoPrompt)
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .opacity(signUp.favoriteDrink.isEmpty ? 0.6 : 1) // Dim text when disabled
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    .disabled(signUp.favoriteDrink.isEmpty) // Prevent interaction when disabled
                }

                Spacer()
            }
            .padding()
            .animation(.easeInOut, value: viewModel.doesntDrink)
        }
    }
}

#Preview("Drinks") {
    DrinkPreferenceView(path: .constant(NavigationPath()))
        .environment(SignUpViewModel())
}
