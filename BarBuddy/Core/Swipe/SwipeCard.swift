//
//  SwipeCard.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.

//  SwipeCard.swift
//  BarBuddy
//
//  Updated 2025‑04‑16
//  Renders a single user profile card from the REST‑API `UserProfile` model.
//

import SwiftUI

struct SwipeCard: View {
    let profile: UserProfile
    private let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.85
    private let cardHeight: CGFloat = 550
    
    private let gradient = LinearGradient(
        colors: [Color.black.opacity(0.7), Color.black.opacity(0.3)],
        startPoint: .bottom,
        endPoint: .top
    )
    
    var displayName: String {
        let name = "\(profile.first_name) \(profile.last_name)".trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? (profile.username.isEmpty ? "No Name" : profile.username) : name
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Card container
            ZStack(alignment: .bottom) {
                // ───────── Profile picture
                if let profilePicURL = profile.profilePicURL {
                    AsyncImage(url: profilePicURL) { phase in
                        switch phase {
                        case .success(let img):
                            img
                                .resizable()
                                .scaledToFill()
                        case .failure(_):
                            placeholderImage
                        case .empty:
                            ZStack {
                                Color.gray.opacity(0.1)
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            }
                        @unknown default:
                            placeholderImage
                        }
                    }
                    .frame(width: cardWidth, height: cardHeight)
                    .clipped()
                } else {
                    placeholderImage
                        .frame(width: cardWidth, height: cardHeight)
                }
                
                gradient
                    .frame(height: 250)
                
                // ───────── Info panel
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(displayName)
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundColor(.white)
                        
                        Text("@\(profile.username)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    // Info items
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.system(size: 14))
                            Text("DOB: \(profile.date_of_birth ?? "N/A")")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.9))
                        
                        if let jobOrUniversity = profile.job_or_university, !jobOrUniversity.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "graduationcap")
                                    .font(.system(size: 14))
                                Text(jobOrUniversity)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white.opacity(0.9))
                        }
                        
                        if let favoriteDrink = profile.favorite_drink, !favoriteDrink.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "wineglass")
                                    .font(.system(size: 14))
                                Text("Fav drink: \(favoriteDrink)")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal)
    }
    
    private var placeholderImage: some View {
        ZStack {
            LinearGradient(
                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                startPoint: .bottom,
                endPoint: .top
            )
            
            Image(systemName: "person.fill")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.5))
                .offset(y: -40)
        }
    }
}

