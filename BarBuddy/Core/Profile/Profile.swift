//
//  Profile.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/5/25.
//  Modified to display the profile picture, info section, and a grid of images in 3 columns.

import SwiftUI

struct ProfileView: View {
    // Optional user parameter.
    // If nil, the profile will use the primary user from the database.
    var user: User? = nil

    // Active user: either the provided user or the primary user.
    var activeUser: User {
        user ?? MockDatabase.getPrimaryUser()
    }
    
    // Computed properties using activeUser.
    var username: String {
        "@\(activeUser.name.lowercased())"
    }
    var name: String { activeUser.name }
    var age: Int { activeUser.age }
    var hometown: String { activeUser.hometown }
    var college: String? { activeUser.school }
    var favoriteDrink: String { activeUser.favoriteDrink }
    var sexualPreference: String { activeUser.preference }
    var bio: String { activeUser.bio }
    var height: String { activeUser.height }
    var images: [String] { activeUser.imageNames }
    
    // Define three flexible grid columns.
    let gridColumns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 1), count: 3)
    
    @State private var selectedImage: String?
    @State private var isImageExpanded = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Username at the top.
                Text(username)
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .foregroundColor(.salmon)
                
                // Profile picture below username.
                if let profilePic = images.first {
                    Image(profilePic)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 7)
                        .frame(maxWidth: .infinity)
                }
                
                // Info Section: user's name, info rows, and bio.
                VStack(alignment: .leading, spacing: 8) {
                    Text(name)
                        .font(.title)
                        .foregroundColor(.darkBlue)
                        .bold()
                    
                    // First row: Age, Height, Hometown.
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "birthday.cake")
                                .foregroundColor(.secondary)
                            Text("\(age)")
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "ruler")
                                .foregroundColor(.secondary)
                            Text(height)
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "house.fill")
                                .foregroundColor(.secondary)
                            Text(hometown)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .font(.subheadline)
                    
                    // Second row: School, Favorite Drink, Sexual Preference.
                    HStack {
                        HStack(spacing: 4) {
                            Text("🎓")
                            Text(college ?? "")
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "wineglass.fill")
                                .foregroundColor(.secondary)
                            Text(favoriteDrink)
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.secondary)
                            Text(sexualPreference)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .font(.subheadline)
                    
                    // Bio.
                    Text("Bio")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.darkBlue)
                    Text(bio)
                        .font(.title3)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                
                // Grid of pictures (3 columns).
                LazyVGrid(columns: gridColumns, spacing: 1) {
                    ForEach(images, id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            // Each cell: 360 x 480 (3:4 ratio, as 1080/3 = 360)
                            .frame(width: 360, height: 480)
                            .clipped()
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        // Toolbar button for Friend Requests remains unchanged.
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: RequestsView()) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.plus")
                        Text("Friend Requests")
                            .font(.subheadline)
                    }
                    .foregroundColor(.darkPurple)
                }
            }
        }
        // Full-screen image viewer.
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
                        Button(action: { isImageExpanded = false }) {
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
        NavigationView {
            ProfileView(user: MockDatabase.getPrimaryUser())
        }
    }
}
