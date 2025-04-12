//
//  AgeVerificationView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

struct AgeVerificationView: View {
    
    @StateObject private var viewModel = AgeVerificationViewModel()
    @State private var path = NavigationPath()
    @Environment(SignUpViewModel.self) var signUpViewModel
    
    private var minimumDate: Date {
        Calendar.current.date(byAdding: .year, value: -120, to: Date()) ?? Date()
    }
    
    private var maximumDate: Date {
        Date()
    }
    
    var body: some View {
        
        /*  - NavigationView changed to NavigationStack due to deprication
            - Our navigation path iterates through NavigationDestination enum
         */
        NavigationStack(path: $path) {
            ZStack {
                Color("DarkBlue")
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    Text("Verify Your Age")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
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
                    
                    Button(action: {
                        signUpViewModel.age = viewModel.verifyAge()
                        if viewModel.proceedToName {
                            
                            // Add destination to the stack
                            path.append(NavigationDestinations.nameEntry)
                        }
                    }) {
                        Text("Verify Age")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("DarkPurple"))
                            .cornerRadius(10)
                    }
                }
                // Iterate through the enum and show coresponding view
                .navigationDestination(for: NavigationDestinations.self) { view in
                    switch view {
                    case .nameEntry: NameEntryView(path: $path)
                    case .location: LocationView(path: $path)
                    case .gender: GenderView(path: $path)
                    case .hometown: HometownView(path: $path)
                    case .school: SchoolView(path: $path)
                    case .drink: DrinkPreferenceView(path: $path)
                    case .smoking: SmokingPreferenceView(path: $path)
                    case .photoPrompt: PhotoPromptView(path: $path)
                    case .photoUpload: PhotoUploadView()
                    }
                }
                .padding()
            }
            .alert("Age Verification Failed", isPresented: $viewModel.showingAgeAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You must be 21 or older to use BarBuddy.")
            }
        }
        .tint(.salmon)
    }
}

#Preview {
    AgeVerificationView()
        .environment(SignUpViewModel())
}
