//
//  PhotoUploadView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import PhotosUI
import SwiftUI

struct PhotoUploadView: View {
    @State private var selectedImages: [UIImage] = []
    @State private var photoPickerItems: [PhotosPickerItem] = []

    let minPhotos = 4
    let maxPhotos = 6

    var body: some View {
        ZStack {
            Color(.darkBlue)
                .ignoresSafeArea()

            VStack {
                if selectedImages.isEmpty {
                    Spacer()
                    
                    Image(systemName: "camera.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color("Salmon"))
                        .padding(.bottom, 30)
                    
                    Text("A Picture is Worth")
                        .font(.title)
                        .foregroundColor(.white)
                        .bold()
                    
                    Text("a Thousand Words")
                        .font(.title)
                        .foregroundColor(Color("Salmon"))
                        .bold()
                        .padding(.bottom, 50)
                    
                    Text("Add 4-6 profile pictures to get started!")
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    PhotosPicker(
                        selection: $photoPickerItems,
                        maxSelectionCount: maxPhotos,
                        selectionBehavior: .ordered,
                        matching: .images
                    ) {
                        HStack {
                            Text("Add Profile Pictures")
                            Image(systemName: "plus.circle.fill")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 50)
                        .background(.darkPurple)
                        .cornerRadius(10)
                        .padding(.bottom, 50)
                    }
                    .onChange(of: photoPickerItems) { oldItems, newItems in
                        Task {
                            for item in newItems {
                                if let data = try? await item.loadTransferable(type: Data.self),
                                   let img = UIImage(data: data)
                                {
                                    selectedImages.append(img)
                                }
                            }
                        }
                    }
                } else {
                    
                    Text("Review Your Photos")
                        .font(.title)
                        .foregroundColor(.white)
                        .bold()
                        .padding(.top)
                    
                    Text("\(selectedImages.count)/\(maxPhotos) added")
                        .font(.caption)
                        .foregroundStyle(.white)

                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 16) {
                            ForEach(selectedImages, id: \.self) { image in
                                ImageTileView(image: image)
                                    .scrollTransition(
                                        axis: .horizontal
                                    ) { content, phase in
                                        return content
                                            .offset(x: phase.value * -90)
                                    }
                                    .containerRelativeFrame(.horizontal)
                                    .clipShape(.rect(cornerRadius: 32))
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .contentMargins(32, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollIndicators(.never)
                    
                    HStack {
                        Text("Create Your Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 190, height: 50)
                            .background(.darkPurple)
                            .cornerRadius(10)
                            
                        PhotosPicker(
                            selection: $photoPickerItems,
                            maxSelectionCount: maxPhotos,
                            selectionBehavior: .ordered,
                            matching: .images
                        ) {
                            Text("Edit")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 50)
                                .background(.darkPurple)
                                .cornerRadius(10)
                                .padding(.leading)
                        }
                        .onChange(of: photoPickerItems) { oldItems, newItems in
                            Task {
                                for (i, item) in newItems.enumerated() {
                                    if let data = try? await item.loadTransferable(type: Data.self),
                                       let img = UIImage(data: data)
                                    {
                                        // Replace photo if previous photo in current index is different
                                        if i < oldItems.count && selectedImages[i] != img {
                                            selectedImages[i] = img
                                        }
                                        // Add more photos when our new selection is bigger than previous one
                                        if !selectedImages.contains(img) {
                                            selectedImages.append(img)
                                        }
                                    }
                                }
                                
                                // Remove last n photos if user deselects n photos
                                if oldItems.count > newItems.count {
                                    selectedImages.removeLast(oldItems.count - newItems.count)
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                    Spacer()
                }
            }
        }
    }
}

#Preview("Photo Upload") {
    @Previewable @State var signUpViewModel = SignUpViewModel()
    PhotoUploadView()
}
