//
//  BarImage.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/13/25.
//

import Foundation
struct BarImage: Codable, Hashable {
    var id: Int?
    var image: String
    var caption: String?
    var uploadedAt: String
}
