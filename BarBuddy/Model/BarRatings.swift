//
//  BarRatings.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/8/25.
//

import Foundation

struct BarRatings: Codable {
    let id: Int
    let bar: Int
    let user: Int
    let rating: Int
    let review: String
    let timeStamp: Date
}
