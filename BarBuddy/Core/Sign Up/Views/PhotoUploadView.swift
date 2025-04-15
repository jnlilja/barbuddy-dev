//
//  PhotoUploadView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct PhotoUploadView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedImages: [UIImage] = []
    @State private var showingImagePicker = false
    @State private var proceedToHome = false
    @Environment(SignUpViewModel.self) var signUpViewModel
    @State private var isLoading: Bool = false
    
    let minPhotos = 4
    let maxPhotos = 6
    
    var body: some View {
        @Bindable var signUpViewModel = signUpViewModel
        
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                    .frame(height: 50)  // Reduced top spacing
                
                Text("Add \(minPhotos)-\(maxPhotos) Photos")
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()
                
                Text("\(selectedImages.count)/\(maxPhotos) photos added")
                    .foregroundColor(Color("Salmon"))
                    .padding(.vertical, 20)
                
                // Center the grid in the middle of the screen
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(0..<maxPhotos, id: \.self) { index in
                            if index < selectedImages.count {
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Button(action: {
                                    showingImagePicker = true
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.1))
                                            .frame(width: 100, height: 100)
                                        
                                        Image(systemName: "plus")
                                            .font(.system(size: 30))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: 400)  // Limit scroll view height
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isLoading = true
                    }
                    Task {
                        try await authViewModel.createUser(data: signUpViewModel)
                    }
                }) {
                    Text("Let's go!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color("DarkPurple"))
                        .cornerRadius(10)
                }
                .disabled(selectedImages.count < minPhotos)
                .opacity(selectedImages.count < minPhotos ? 0.6 : 1)
                .padding(.bottom, 50)
            }
            if isLoading {
                LoadingScreenView()
                    .navigationBarBackButtonHidden()
                    .transition(.blurReplace)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImages: $selectedImages, maxPhotos: maxPhotos)
        }
    }
}

#Preview("Photo Upload") {
    PhotoUploadView()
        .environment(SignUpViewModel())
        .environmentObject(AuthViewModel())
}
