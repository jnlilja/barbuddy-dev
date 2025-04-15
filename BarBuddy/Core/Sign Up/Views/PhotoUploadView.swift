//
//  PhotoUploadView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import PhotosUI
import SwiftUI

struct PhotoUploadView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedImages: [UIImage] = []
    @State private var photoPickerItems: [PhotosPickerItem] = []
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

                Text("Add \(minPhotos)-\(maxPhotos) Photos")
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()

                Text("\(selectedImages.count)/\(maxPhotos) photos added")
                    .foregroundColor(Color("Salmon"))
                    .padding(.vertical, 20)

                // Center the grid in the middle of the screen

                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ],
                    spacing: 15
                ) {
                    ForEach(0..<6) { index in
                        PhotosPicker(
                            selection: $photoPickerItems,
                            maxSelectionCount: maxPhotos,
                            matching: .images
                        ) { [selectedImages] in
                            ZStack {
                                if index < selectedImages.count {
                                    Image(uiImage: selectedImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 10)
                                        )
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.black.opacity(0.1))
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
                .onChange(of: photoPickerItems) { _, _ in
                    Task {
                        for (i, item) in photoPickerItems.enumerated() {
                            if let data = try? await item.loadTransferable(
                                type: Data.self
                            ),
                                let image = UIImage(data: data)
                            {
                                if !selectedImages.isEmpty && i < selectedImages.count {
                                    photoPickerItems[i] = item
                                    selectedImages[i] = image
                                }
                                else if selectedImages.count < maxPhotos {
                                    selectedImages.append(image)
                                }
                            }
                        }
                    }
                }
                .onChange(of: photoPickerItems.count) { oldValue, newValue in
                    if newValue < oldValue {
                        selectedImages.removeAll()
                    }
                }
                
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
    }
}

#Preview("Photo Upload") {
    PhotoUploadView()
        .environment(SignUpViewModel())
        .environmentObject(AuthViewModel())
}
