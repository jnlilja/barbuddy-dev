//
//  User.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/23/25.
//

import Foundation

struct User: Codable, Hashable, Identifiable {
    var id: Int? // Ignore id for encoding since database will generate one
    var username: String
    var firstName: String
    var lastName: String
    var email: String
    var password: String
    var dateOfBirth: String
    var hometown: String
    var jobOrUniversity: String
    var favoriteDrink: String
    var location: Location?
    var profilePictures: [ProfilePicture]?
    var matches: String
    var swipes: String
    var voteWeight: Int
    var accountType: String
    var sexualPreference: String
    var phoneNumber: String?
}

