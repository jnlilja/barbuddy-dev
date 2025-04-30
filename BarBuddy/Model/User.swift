//
//  User.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 4/23/25.
//

import Foundation

struct User: Codable, Hashable, Identifiable {
    var id: Int?
    var username: String
    var firstName: String
    var lastName: String
    var email: String
    var password: String
    var dateOfBirth: String?
    var hometown: String
    var jobOrUniversity: String
    var favoriteDrink: String
    var location: String
    var profilePictures: String
    var matches: String
    var swipes: String
    var voteWeight: Int
    var accountType: String
    var sexualPreference: String?
    var phoneNumber: String?
    
    var displayName: String { "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces) }
}

struct CreateUserRequest: Codable {
    let username: String
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let confirmPassword: String
    let dateOfBirth: String?
    let hometown: String
    let jobOrUniversity: String
    let favoriteDrink: String
    var profilePictures: String
    let accountType: String
    let sexualPreference: String?
    let phoneNumber: String?
}
