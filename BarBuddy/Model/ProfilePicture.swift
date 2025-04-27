//
//  ProfilePicture.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/23/25.
//

import Foundation

struct ProfilePicture: Codable, Hashable, Identifiable {
    var id: Int?
    var url: String
    var isPrimary: Bool
    let uploadedAt: String
}
