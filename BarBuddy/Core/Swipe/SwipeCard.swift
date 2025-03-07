//
//  SwipeCard.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

import SwiftUI

struct SwipeCard: View {
    // Use the same images as in Profile.swift
    let images = [
        "TestImage",
        "guy1",
        "guy2",
        "guy3"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Photo gallery with swipable images
            TabView {
                ForEach(images, id: \.self) { imageName in
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 457)  // same as in Profile.swift
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .frame(height: 457)
            .tabViewStyle(PageTabViewStyle())
            
            // User info card below photos
            VStack(alignment: .leading, spacing: 12) {
                // Name Row with location
                HStack {
                    Text("Ashley")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color("DarkPurple"))
                    
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(Color("NeonPink"))
                        .font(.system(size: 20))
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                        Text("Hideaway")
                    }
                    .foregroundColor(Color("DarkPurple"))
                }
                
                Divider()
                
                // First info row: Age, Height, Hometown
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "birthday.cake")
                            .foregroundColor(.secondary)
                        Text("23")
                    }
                    .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "ruler")
                            .foregroundColor(.secondary)
                        Text("5'11")
                    }
                    .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "house.fill")
                            .foregroundColor(.secondary)
                        Text("San Diego")
                    }
                    .frame(maxWidth: .infinity)
                }
                .font(.system(size: 16))
                .foregroundColor(Color("DarkPurple"))
                
                // Second info row: School, Favorite Drink, and Sexual Preference
                HStack {
                    HStack(spacing: 4) {
                        Text("🎓")
                        Text("SDSU")
                    }
                    .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "wineglass.fill")
                            .foregroundColor(.secondary)
                        Text("Tequila")
                    }
                    .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 4) {
                        Text("⚥")
                        Text("Straight")
                    }
                    .frame(maxWidth: .infinity)
                }
                .font(.system(size: 16))
                .foregroundColor(Color("DarkPurple"))
                
                // Bio/Description with scaled quote images
                HStack(alignment: .center, spacing: 4) {
                    Image("fowardQuote")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 24)
                        .italic()
                        .offset(y: -8)
                    
                    Text("Outgoing")
                    
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
        SwipeCard()
            .previewLayout(.device)
            .previewDisplayName("SwipeCard")
    }
}
