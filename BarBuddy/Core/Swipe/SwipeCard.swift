//
//  SwipeCard.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 2/25/25.
//

//
//  SwipeCard.swift
//  BarBuddy
//
//  Updated 2025‑04‑16
//  Renders a single user profile card from the REST‑API `UserProfile` model.
//

import SwiftUI

struct SwipeCard: View {
    let profile: User
    private let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.85

    // Convenience
    var displayName: String {
        let name = "\(profile.firstName) \(profile.lastName)".trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? profile.username : name
    }

    var body: some View {
        VStack(spacing: 0) {
            // ───────── Profile picture
//            AsyncImage(url: profile.profilePicURL) { phase in
//                switch phase {
//                case .success(let img): img.resizable().scaledToFill()
//                case .failure(_):       Color.gray.opacity(0.3)
//                case .empty:            ProgressView()
//                @unknown default:       Color.gray.opacity(0.3)
//                }
//            }
//            .frame(width: cardWidth, height: 400)
//            .clipped()

            // ───────── Info panel
            VStack(alignment: .leading, spacing: 8) {
                Text(displayName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text("@\(profile.username)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))

                Divider().overlay(Color.white)

                Label("DOB: \(profile.dateOfBirth ?? "")", systemImage: "calendar")
                if !profile.jobOrUniversity.isEmpty {
                    Label(profile.jobOrUniversity, systemImage: "graduationcap")
                }
                if !profile.favoriteDrink.isEmpty {
                    Label("Fav drink: \(profile.favoriteDrink)", systemImage: "wineglass")
                }
            }
            .labelStyle(.titleAndIcon)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.6))
        }
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(radius: 8)
        .padding(.horizontal)
    }
}

