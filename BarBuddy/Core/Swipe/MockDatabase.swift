//
//  MockDatabase.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/7/25.
//  Modified to include a primary user and friends.

import Foundation

struct MockDatabase {
    static func getPrimaryUser() -> User {
        return User(
            id: UUID().uuidString, name: "Alex",
            age: 30,
            height: "6'1\"",
            hometown: "Austin",
            school: "UT Austin",
            favoriteDrink: "Craft Beer",
            preference: "Straight",
            bio: "Lover of live music and outdoor adventures.",
            imageNames: ["TestImage", "guy2"]
        )
    }
    
    static func getFriends() -> [User] {
        return [
            User(
                id: UUID().uuidString, name: "Ashley",
                age: 23,
                height: "5'11\"",
                hometown: "San Diego",
                school: "SDSU",
                favoriteDrink: "Tequila",
                preference: "Straight",
                bio: "Outgoing and adventurous.",
                imageNames: ["TestImage", "guy1", "guy2"]
            ),
            User(
                id: UUID().uuidString, name: "John",
                age: 28,
                height: "6'0\"",
                hometown: "Los Angeles",
                school: "UCLA",
                favoriteDrink: "Whiskey",
                preference: "Gay",
                bio: "Passionate and creative.",
                imageNames: ["guy3", "TestImage", "guy2"]
            ),
            User(
                id: UUID().uuidString, name: "Emily",
                age: 26,
                height: "5'5\"",
                hometown: "New York",
                school: "NYU",
                favoriteDrink: "Wine",
                preference: "Bisexual",
                bio: "Smart and witty.",
                imageNames: ["guy1", "guy3", "TestImage"]
            )
        ]
    }
    
    // Optional helper if you need all users.
    static func getAllUsers() -> [User] {
        var allUsers = getFriends()
        allUsers.insert(getPrimaryUser(), at: 0)
        return allUsers
    }
}
