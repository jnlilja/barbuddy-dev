//
//  BarSwipeCard.swift
//  BarBuddy
//
//  Created by Gwinyai Nyatsoka on 9/5/2025.
//

import SwiftUI

struct BarSwipeCard: View {
    let profile: Bar
    private let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.85

    // Convenience
    var displayName: String {
        let name = "\(profile.name)".trimmingCharacters(in: .whitespaces)
        return name
    }

    var body: some View {
        VStack(spacing: 0) {
            // ───────── Profile picture
            let barImage = profile.images?.first?.image ?? ""
            let barImageURL = URL(string: barImage)
            AsyncImage(url: barImageURL) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                case .failure(_):       Color.gray.opacity(0.3)
                case .empty:            ProgressView()
                @unknown default:       Color.gray.opacity(0.3)
                }
            }
            .frame(width: cardWidth, height: 400)
            .clipped()

            // ───────── Info panel
            VStack(alignment: .leading, spacing: 8) {
                Text(displayName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

//                Text("\(profile.activityLevel)")
//                    .font(.subheadline)
//                    .foregroundColor(.white.opacity(0.8))

                Divider().overlay(Color.white)

                Label("Price: \(profile.averagePrice ?? "-")", systemImage: "dollarsign.circle.fill")

            }
            .labelStyle(.titleAndIcon)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black)
        }
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(radius: 8)
        .padding(.horizontal)
    }
}
