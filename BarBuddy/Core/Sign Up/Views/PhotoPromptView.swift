//
//  PhotoPromptView.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//


import SwiftUI

struct PhotoPromptView: View {
    @State private var proceedToPhotoUpload = false
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
            Color("DarkBlue")
                .ignoresSafeArea()
            
            VStack {
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
                
                Text("Add some photos to complete your profile")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    proceedToPhotoUpload = true
                    path.append(SignUpNavigation.photoUpload)
                }) {
                    Text("Add Photos")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color("DarkPurple"))
                        .cornerRadius(10)
                }
                .padding(.bottom, 50)
            }
            .padding()
        }
    }
}

// Photo Flow Previews
#Preview("Photo Prompt") {
    PhotoPromptView(path: .constant(NavigationPath()))
}
