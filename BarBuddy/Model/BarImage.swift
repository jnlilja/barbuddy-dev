//
//  BarImage.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/13/25.
//

import Foundation

struct BarImage: Codable, Identifiable, Hashable {
    var id: Int?
    let bar: Int
    let image: String
    let caption: String?
    let uploadedAt: String?
    private enum CodingKeys: String, CodingKey {
        case id, bar, image, caption
        case uploadedAt = "uploaded_at"
    }
}
