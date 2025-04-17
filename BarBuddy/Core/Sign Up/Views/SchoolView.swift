//
//  SchoolView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct SchoolView: View {
    @State private var school             = ""
    @State private var currentlyAttending = false
    @State private var major              = ""
    @State private var showOnProfile      = true
    @Binding var path: NavigationPath
    @EnvironmentObject var viewModel: SignUpViewModel

    var body: some View {
        ZStack {
            Color("DarkBlue").ignoresSafeArea()

            VStack {
                Spacer()

                ProgressDots(currentPage: 4, totalPages: 7)

                VStack(spacing: 25) {
                    Text("Where did you go to school?")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    TextField("Enter your school", text: $school)
                        .textFieldStyle(CustomTextFieldStyle())

                    Button {
                        currentlyAttending.toggle()
                    } label: {
                        HStack {
                            Image(systemName: currentlyAttending ? "checkmark.square.fill" : "square")
                                .foregroundColor(Color("Salmon"))
                                .font(.system(size: 20))
                            Text("I currently attend this school")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)

                    if currentlyAttending {
                        TextField("What's your major?", text: $major)
                            .textFieldStyle(CustomTextFieldStyle())
                            .transition(.opacity)
                    }

                    Button("Show on my profile") {
                        showOnProfile.toggle()
                    }
                    .padding(.horizontal)
                    .foregroundColor(.white)

                    Button("Continue") {
                        // write back into shared view‑model
                        viewModel.jobOrUniversity = school
                        path.append(SignUpNavigation.drink)
                    }
                    .disabled(school.isEmpty || (currentlyAttending && major.isEmpty))
                    .opacity(school.isEmpty || (currentlyAttending && major.isEmpty) ? 0.6 : 1)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color("DarkPurple"))
                    .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
            .animation(.easeInOut, value: currentlyAttending)
        }
    }
}

#Preview("School") {
    SchoolView(path: .constant(NavigationPath()))
        .environmentObject(SignUpViewModel())
}
