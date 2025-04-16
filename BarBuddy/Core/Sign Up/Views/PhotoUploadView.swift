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
                    ForEach(0..<6) { i in
                        PhotosPicker(
                            selection: $photoPickerItems,
                            maxSelectionCount: maxPhotos,
                            selectionBehavior: .ordered,
                            matching: .images
                        ) { [selectedImages] in
                            
                            if i < selectedImages.count {
                                ImageTileView(image: selectedImages[i])
                            } else {
                                EmptyImageTileView()
                            }
                        }
                    }
                }
                .padding()
                .onChange(of: photoPickerItems) { oldValue, newValue in
                    // Planning to make the logic better but this will do for now
                    selectedImages.removeAll()
                    Task {
                        for item in photoPickerItems {
                            if let data = try? await item.loadTransferable(
                                type: Data.self
                            ),
                               let image = UIImage(data: data)
                            {
                                selectedImages.append(image)
                            }
                        }
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
