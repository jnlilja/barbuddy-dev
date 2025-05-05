//
//  SignUpUser.swift
//  BarBuddy
//
//  Created by Gwinyai Nyatsoka on 2/5/2025.
//

import SwiftUI

struct SignUpUser: Codable {
    var username: String
    var first_name: String
    var last_name: String
    var email: String
    var password: String
    var confirm_password: String
    var date_of_birth: String
    var hometown: String
    var job_or_university: String
    var favorite_drink: String
    var profile_pictures: [String: String]?
    var account_type: String
    var sexual_preference: String
}
