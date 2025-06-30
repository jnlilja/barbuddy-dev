//
//  DrinkPreferenceView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

struct DrinkPreferenceView: View {
    @State private var favoriteDrink = ""
    @Binding var path: NavigationPath
    @Environment(SignUpViewModel.self) var viewModel
    @State private var proceedToNextPage = false

    var body: some View {
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
                        TextField("Enter your favorite drink", text: $favoriteDrink)
                            .textFieldStyle(CustomTextFieldStyle())
                    }

                    Button {
                        viewModel.doesntDrink.toggle()
                        if viewModel.doesntDrink {
                            favoriteDrink = "I don't drink"
                        } else {
                            favoriteDrink = ""
                        }
                    } label: {
                        HStack {
                            Image(systemName: viewModel.doesntDrink ? "checkmark.square.fill" : "square")
                                .foregroundColor(Color("Salmon"))
                                .font(.system(size: 20))
                            Text("I don't drink ")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)

                    Button(action: {
                        viewModel.favoriteDrink = favoriteDrink
                        //path.append(SignUpNavigation.photoUpload)
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .opacity(favoriteDrink.isEmpty ? 0.6 : 1) // Dim text when disabled
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    .disabled(favoriteDrink.isEmpty) // Prevent interaction when disabled
                }

                Spacer()
            }
            .padding()
            .animation(.easeInOut, value: viewModel.doesntDrink)
        }
    }
}

#Preview("Drinks") {
    @Previewable @State var signUpViewModel = SignUpViewModel()
    DrinkPreferenceView(path: .constant(NavigationPath()))
        .environment(signUpViewModel)
}
