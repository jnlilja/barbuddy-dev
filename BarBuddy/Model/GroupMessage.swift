//
//  GroupMessage.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/1/25.
//

import Foundation
struct GroupMessage: Codable {
    var id: Int
    var group: Int
    var sender: Int
    var content: String
    var timestamp: String
    var sendUsername: String
    var groupName: String
}
