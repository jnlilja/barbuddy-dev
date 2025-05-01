//
//  Match.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/1/25.
//

import Foundation
 struct Match: Codable {
    var id: Int
    var user1: Int
    var user1Details: MatchUser
    var user2: Int
    var user2Details: MatchUser
    var status: String
    var createdAt: String
    var disconnectedBy: Int
    var disconnectedByUsername: String
}
