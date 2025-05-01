//
//  GroupChat.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/1/25.
//

import Foundation
struct GroupChat: Codable {
    var id: Int
    var name: String
    var members: [Int]
    var createdAt: String
}
