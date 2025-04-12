//
//  NameEntryView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct NameEntryView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var proceedToLocation = false
    @Binding var path: NavigationPath
    @Environment(SignUpViewModel.self) var viewModel
    
    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ProgressDots(currentPage: 0, totalPages: 7)
                
                VStack(spacing: 25) {
                    Text("What's Your Name?")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    Button(action: {
                        viewModel.name = "\(firstName) \(lastName)"
                        proceedToLocation = true
                        path.append(NavigationDestinations.location)
                        
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                    .opacity(firstName.isEmpty || lastName.isEmpty ? 0.6 : 1)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

// Profile Info Previews
#Preview("Name") {
    NameEntryView(path: .constant(NavigationPath()))
        .environment(SignUpViewModel())
}
