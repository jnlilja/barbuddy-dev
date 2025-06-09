//
//  User.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/7/25.
//

import Foundation

struct User: Identifiable, Codable, Hashable {
    var id: Int?
    var username: String
    var firstName: String
    var lastName: String
    let email: String
    let dateOfBirth: Date
    var hometown: String
    var jobOrUniversity: String
    var favoriteDrink: String
    var location: String
    var profilePictures: [ProfilePicture]
    var accountType: String // "user" or "business"
    var sexualPreference: String // "Straight
    var phoneNumber: String
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
