//
//  BarVote.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/12/25.
//

import Foundation
struct BarVote: Codable {
    var id: Int?
    var bar: Int
    var waitTime: String
    var timeStamp: Date?
}
