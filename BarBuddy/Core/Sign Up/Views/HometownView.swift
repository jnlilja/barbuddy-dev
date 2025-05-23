//
//  HometownView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

struct HometownView: View {
    @State private var hometown = ""
    @State private var showOnProfile = true
    @State private var proceedToNextPage = false
    @Binding var path: NavigationPath
    @EnvironmentObject var viewModel: SignUpViewModel

    var body: some View {
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

                    TextField("Enter your hometown", text: $hometown)
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
                        proceedToNextPage = true
                        // write back into your ObservableObject directly—drop the `$`
                        viewModel.hometown = hometown
                        //path.append(SignUpNavigation.school)
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    .disabled(hometown.isEmpty)
                    .opacity(hometown.isEmpty ? 0.6 : 1)
                }

                Spacer()
            }
            .padding()
        }
    }
}

#Preview("Hometown") {
    HometownView(path: .constant(NavigationPath()))
        // inject using environmentObject
        .environmentObject(SignUpViewModel())
}
