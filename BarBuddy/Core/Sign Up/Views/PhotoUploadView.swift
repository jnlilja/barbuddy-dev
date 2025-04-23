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
    @EnvironmentObject var signUpViewModel: SignUpViewModel

    @State private var selectedImages: [UIImage] = []
    @State private var photoPickerItems: [PhotosPickerItem] = []
    @State private var isLoading: Bool = false

    let minPhotos = 4
    let maxPhotos = 6

    var body: some View {
        ZStack {
            Color("DarkBlue").ignoresSafeArea()

            VStack {
                Spacer()

                Text("Add \(minPhotos)-\(maxPhotos) Photos")
                    .font(.title).bold()
                    .foregroundColor(.white)

                Text("\(selectedImages.count)/\(maxPhotos) photos added")
                    .foregroundColor(Color("Salmon"))
                    .padding(.vertical, 20)

                // snapshot of the @State array for Sendable closure
                let imageSnapshot = selectedImages

                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3),
                          spacing: 15)
                {
                    ForEach(0..<maxPhotos, id: \.self) { i in
                        PhotosPicker(
                            selection: $photoPickerItems,
                            maxSelectionCount: maxPhotos,
                            selectionBehavior: .ordered,
                            matching: .images
                        ) {
                            if i < imageSnapshot.count {
                                ImageTileView(image: imageSnapshot[i])
                            } else {
                                EmptyImageTileView()
                            }
                        }
                    }
                }
                .padding()
                .onChange(of: photoPickerItems) { _, newItems in
                    selectedImages.removeAll()
                    Task {
                        for item in newItems {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let img  = UIImage(data: data)
                            {
                                selectedImages.append(img)
                            }
                        }
                    }
                }

                Spacer()

                Button(action: {
                    withAnimation { isLoading = true }
                    Task {
                        let profile = signUpViewModel.buildProfile()
                        await authViewModel.signUp(
                            profile: profile,
                            password: signUpViewModel.newPassword
                        )
                    }
                }) {
                    Text("Let's go!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .opacity(selectedImages.count < minPhotos ? 0.6 : 1) // Dim text when disabled
                        .frame(width: 300, height: 50)
                        .background(Color("DarkPurple"))
                        .cornerRadius(10)
                }
                .disabled(selectedImages.count < minPhotos) // Prevent interaction when disabled
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
        .environmentObject(SignUpViewModel())
        .environmentObject(AuthViewModel())
}
