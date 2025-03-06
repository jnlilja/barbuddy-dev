//
//  Profile.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/5/25.
//

import SwiftUI

struct ProfileView: View {
    // MARK: - Example Data
    let username: String = "@user123"
    let name: String = "John Smith"
    let age: Int = 25
    
    let occupation: String = "Occupation"
    let hometown: String = "Hometown"
    let sexualPreference: String = "Straight"
    let favoriteDrink: String = "Favorite Drink"
    let college: String? = "School" // Optional
    let height: String = "Height"   // Newly added
    
    let bio: String = "user bio"
    
    // Images for the user's gallery
    let images = [
        "TestImage",
        "guy1",
        "guy2",
        "guy3"
    ]
    
    @State private var selectedImage: String?
    @State private var isImageExpanded = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // Username above photos
                Text(username)
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .foregroundColor(.salmon)
                
                // MARK: - Photo Gallery at Top
                TabView {
                    ForEach(images, id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 457)
                            .cornerRadius(20)
                            .padding(.horizontal, 16)
                            .clipped()
                            .onTapGesture {
                                selectedImage = imageName
                                isImageExpanded = true
                            }
                    }
                }
                .frame(height: 457)
                .tabViewStyle(PageTabViewStyle())
                .edgesIgnoringSafeArea(.top)
                
                // MARK: - White background for Name
                VStack(alignment: .leading, spacing: 0) {
                    Text(name)
                        .font(.title)
                        .foregroundColor(.darkBlue)
                        .bold()
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                        .padding(.horizontal)
                }
                .background(Color.white)
                
                Divider()
                
                // MARK: - Info rows
                VStack(alignment: .leading, spacing: 0) {
                    
                    // First Row: Age, Height, Hometown
                    HStack {
                        // Age
                        HStack(spacing: 4) {
                            Image(systemName: "birthday.cake")
                                .foregroundColor(.secondary)
                            Text("\(age)")
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Height
                        HStack(spacing: 4) {
                            Image(systemName: "ruler")
                                .foregroundColor(.secondary)
                            Text(height)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Hometown
                        HStack(spacing: 4) {
                            Image(systemName: "house.fill")
                                .foregroundColor(.secondary)
                            Text(hometown)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .font(.subheadline)
                    .padding(.vertical, 16)
                    .padding(.horizontal)
                    
                    // Second Row: School, Favorite Drink, Sexual Preference
                    HStack {
                        // School
                        HStack(spacing: 4) {
                            Text("🎓")
                            Text(college ?? "")
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Favorite Drink
                        HStack(spacing: 4) {
                            Image(systemName: "wineglass.fill")
                                .foregroundColor(.secondary)
                            Text(favoriteDrink)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Sexual Preference
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.secondary)
                            Text(sexualPreference)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .font(.subheadline)
                    .padding(.vertical, 16)
                    .padding(.horizontal)
                }
                .background(Color.white)
                
                Divider()
                
                // MARK: - About Me (white background again)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bio")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.darkBlue)
                        .padding(.top, 16)
                    
                    Text(bio)
                        .font(.title3)
                }
                .padding(.bottom, 16)
                .padding(.horizontal)
                .background(Color.white)
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        // MARK: - Full-Screen Cover for Expanded Image
        .fullScreenCover(isPresented: $isImageExpanded) {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                if let selectedImage = selectedImage {
                    Image(selectedImage)
                        .resizable()
                        .scaledToFit()
                        .edgesIgnoringSafeArea(.all)
                }
                
                VStack {
                    HStack {
                        Button(action: {
                            isImageExpanded = false
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.title2)
                                .padding()
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
