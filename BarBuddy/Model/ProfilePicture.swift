//
//  ProfilePicture.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/8/25.
//

import Foundation

struct ProfilePicture: Codable, Identifiable, Hashable {
    let id: Int
    let image: String // Image URL
    let isPrimary: Bool
    let uploadedAt: Date
}
