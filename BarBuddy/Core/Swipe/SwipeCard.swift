//
//  SwipeCard.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

struct SwipeCard: View {
    let user: User

    var body: some View {
        VStack(spacing: 0) {
            // Photo gallery with swipable images.
            TabView {
                ForEach(user.imageNames, id: \.self) { imageName in
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 457)
                        .clipShape(RoundedRectangle(cornerRadius: 12)) // Reduced corner radius for softer look
                }
            }
            .frame(height: 457)
            .tabViewStyle(PageTabViewStyle())
            
            // User info card below photos.
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
                
                // Bio/Description with decorative quote images.
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
        .padding()
    }
}

struct SwipeCard_Previews: PreviewProvider {
    static var previews: some View {
        SwipeCard(user: User(name: "Preview", age: 25, height: "5'9\"", hometown: "Sample City", school: "Sample Uni", favoriteDrink: "Coffee", preference: "Open", bio: "Loves adventure", imageNames: ["TestImage"]))
            .previewLayout(.device)
            .previewDisplayName("SwipeCard")
    }
}
