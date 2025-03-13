//
//  Profile.swift
//  BarBuddy
//
//  Modified to be dynamic using data from MockDatabase.
//  Fixes:
//  - Photos in the grid use a fixed size (calculated from screen width) so they display as small squares.
//  - Tapping a photo shows an enlarged, full-screen preview.
//  - The "Info" tab now fills the available width without narrowing the background.

import SwiftUI

struct ProfileView: View {
    // Load the primary user from the mock database.
    private let primaryUser: User = MockDatabase.getPrimaryUser()
    
    @State private var selectedTab = 0
    @State private var selectedImage: String? = nil
    @State private var isImageExpanded = false
    
    // Compute grid cell width based on screen width.
    // Assumes 16 pts horizontal padding on each side and 15 pts spacing between cells.
    private var gridCellWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let totalHorizontalPadding: CGFloat = 16 * 2
        let totalSpacing: CGFloat = 15 * 2
        return (screenWidth - totalHorizontalPadding - totalSpacing) / 3
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Profile Header with Dynamic Profile Picture.
                    if let profilePic = primaryUser.imageNames.first {
                        Image(profilePic)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 7)
                            .padding(.top, 20)
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .padding(.top, 20)
                    }
                    
                    // Name and Verification.
                    HStack(spacing: 8) {
                        Text(primaryUser.name)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color("NeonPink"))
                            .font(.system(size: 24))
                    }
                    
                    // Custom Segmented Control.
                    HStack(spacing: 0) {
                        TabButton(text: "Photos", isSelected: selectedTab == 0) {
                            withAnimation { selectedTab = 0 }
                        }
                        TabButton(text: "Info", isSelected: selectedTab == 1) {
                            withAnimation { selectedTab = 1 }
                        }
                    }
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(25)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Content based on selected tab.
                    if selectedTab == 0 {
                        // Photos Grid using fixed cell sizes.
                        LazyVGrid(columns: [
                            GridItem(.fixed(gridCellWidth), spacing: 15),
                            GridItem(.fixed(gridCellWidth), spacing: 15),
                            GridItem(.fixed(gridCellWidth))
                        ], spacing: 15) {
                            ForEach(primaryUser.imageNames, id: \.self) { imageName in
                                ZStack(alignment: .topTrailing) {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: gridCellWidth, height: gridCellWidth)
                                        .clipped()
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            selectedImage = imageName
                                            isImageExpanded = true
                                        }
                                    
                                    // Edit Button for each photo.
                                    Button(action: {
                                        // Add photo edit action here.
                                    }) {
                                        Circle()
                                            .fill(Color("Salmon"))
                                            .frame(width: 30, height: 30)
                                            .overlay(
                                                Image(systemName: "pencil")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.white)
                                            )
                                    }
                                    .padding(8)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    } else {
                        // Info View: Dynamically display user's details.
                        VStack(alignment: .leading, spacing: 20) {
                            InfoSection(title: "Basic Info", items: [
                                InfoItem(icon: "calendar", text: "\(primaryUser.age) years old"),
                                InfoItem(icon: "ruler", text: primaryUser.height),
                                InfoItem(icon: "mappin.circle.fill", text: primaryUser.hometown)
                            ])
                            
                            InfoSection(title: "Work & Education", items: [
                                InfoItem(icon: "graduationcap.fill", text: primaryUser.school)
                            ])
                            
                            InfoSection(title: "Preferences", items: [
                                InfoItem(icon: "wineglass.fill", text: "Favorite Drink: \(primaryUser.favoriteDrink)"),
                                InfoItem(icon: "person.2.fill", text: "Preference: \(primaryUser.preference)")
                            ])
                            
                            Text(primaryUser.bio)
                                .font(.footnote)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.top, 5)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top)
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color("DarkBlue").ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: RequestsView()) {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.plus")
                            Text("Friend Requests")
                                .font(.subheadline)
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            // Full-Screen Photo Viewer (only triggered when a photo is tapped).
            .fullScreenCover(isPresented: $isImageExpanded) {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    if let selectedImage = selectedImage {
                        Image(selectedImage)
                            .resizable()
                            .scaledToFit()
                            .background(Color.black)
                            .onTapGesture {
                                // Tapping the full-screen image dismisses it.
                                isImageExpanded = false
                            }
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
}

struct TabButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(width: 120, height: 40)
                .background(isSelected ? Color("Salmon") : Color.clear)
                .cornerRadius(25)
        }
    }
}

struct InfoSection: View {
    let title: String
    let items: [InfoItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            ForEach(items) { item in
                HStack {
                    Image(systemName: item.icon)
                        .foregroundColor(Color("Salmon"))
                    Text(item.text)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
            }
        }
    }
}

struct InfoItem: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
