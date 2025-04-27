//
//  HometownView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

struct HometownView: View {
    @State private var showOnProfile = true
    @Binding var path: NavigationPath
    @Environment(SignUpViewModel.self) var viewModel

    var body: some View {
        @Bindable var signUp = viewModel
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()

            VStack {
                Spacer()

                ProgressDots(currentPage: 3, totalPages: 7)

                VStack(spacing: 25) {
                    Text("Where are you from?")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .multilineTextAlignment(.center)

                    TextField("Enter your hometown", text: $signUp.hometown)
                        .textFieldStyle(CustomTextFieldStyle())

                    Button(action: {
                        showOnProfile.toggle()
                    }) {
                        HStack {
                            Image(systemName: showOnProfile ? "checkmark.square.fill" : "square")
                                .foregroundColor(Color("Salmon"))
                                .font(.system(size: 20))
                            Text("Show on my profile")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)

                    Button(action: {
                        path.append(SignUpNavigation.school)
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    .disabled(signUp.hometown.isEmpty)
                    .opacity(signUp.hometown.isEmpty ? 0.6 : 1)
                }

                Spacer()
            }
            .padding()
        }
    }
}

#Preview("Hometown") {
    HometownView(path: .constant(NavigationPath()))
        .environment(SignUpViewModel())
}
