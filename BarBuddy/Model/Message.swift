//
//  Message.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/18/25.
//

import Foundation

struct Message: Identifiable, Codable {
    let id: Int
    var sender: Int
    var recepient: Int
    var content: String
    var timestamp: String
    var isRead: Bool
    var senderUsername: String
    var recepientUsername: String
}

// Only for testing
struct MockMessage: Identifiable, Codable {
    let id = UUID()
    let text: String
    let isIncoming: Bool
}
