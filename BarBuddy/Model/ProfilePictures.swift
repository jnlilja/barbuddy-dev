//
//  ProfilePicture.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/23/25.
//

import Foundation

struct ProfilePictures: Codable, Hashable, Identifiable {
    var id: Int?
    var image: String
    var isPrimary: Bool
    let uploadedAt: String
}
