//
//  FriendProfile.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/12/25.
//

import SwiftUI

struct FriendProfile: View {
    let user: User

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Photo Gallery
                TabView {
                    ForEach(user.imageNames, id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 457)
                            .clipped()
                    }
                }
                .frame(height: 457)
                .tabViewStyle(PageTabViewStyle())
                
                // MARK: - Info Card
                VStack(alignment: .leading, spacing: 12) {
                    // Name row with verification and hometown tag.
                    HStack {
                        Text(user.name)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color("DarkPurple"))
                        
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color("NeonPink"))
                            .font(.system(size: 20))
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                            Text(user.hometown)
                        }
                        .foregroundColor(Color("DarkPurple"))
                    }
                    
                    Divider()
                    
                    // First row: Age, Height, Hometown.
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "birthday.cake")
                                .foregroundColor(.secondary)
                            Text("\(user.age)")
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "ruler")
                                .foregroundColor(.secondary)
                            Text(user.height)
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "house.fill")
                                .foregroundColor(.secondary)
                            Text(user.hometown)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .font(.system(size: 16))
                    .foregroundColor(Color("DarkPurple"))
                    
                    // Second row: School, Favorite Drink, and Preference.
                    HStack {
                        HStack(spacing: 4) {
                            Text("🎓")
                            Text(user.school)
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "wineglass.fill")
                                .foregroundColor(.secondary)
                            Text(user.favoriteDrink)
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 4) {
                            Text("⚥")
                            Text(user.preference)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .font(.system(size: 16))
                    .foregroundColor(Color("DarkPurple"))
                    
                    // Bio with decorative quotes.
                    HStack(alignment: .center, spacing: 4) {
                        Image("fowardQuote")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 24)
                            .italic()
                            .offset(y: -8)
                        
                        Text(user.bio)
                        
                        Image("backwardQuote")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 24)
                            .italic()
                            .offset(y: -8)
                    }
                    .font(.system(size: 24, weight: .light).italic())
                    .foregroundColor(Color("Salmon"))
                    .padding(.top, 12)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FriendProfile_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FriendProfile(user: User(id: UUID().uuidString, name: "Preview", age: 25, height: "5'9\"", hometown: "Sample City", school: "Sample Uni", favoriteDrink: "Coffee", preference: "Open", bio: "Loves adventure", imageNames: ["TestImage"]))
        }
    }
}
