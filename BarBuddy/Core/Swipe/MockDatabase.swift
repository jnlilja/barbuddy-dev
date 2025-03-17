//
//  MockDatabase.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 3/7/25.
//

import Foundation

struct MockDatabase {
    static func getUsers() -> [User] {
        return [
            User(name: "Ashley", age: 23, height: "5'11\"", hometown: "San Diego", school: "SDSU", favoriteDrink: "Tequila", preference: "Straight", bio: "Outgoing and adventurous", imageNames: ["TestImage", "guy1", "guy2"]),
            User(name: "John", age: 28, height: "6'0\"", hometown: "Los Angeles", school: "UCLA", favoriteDrink: "Whiskey", preference: "Gay", bio: "Passionate and creative", imageNames: ["guy3", "TestImage", "guy2"]),
            User(name: "Emily", age: 26, height: "5'5\"", hometown: "New York", school: "NYU", favoriteDrink: "Wine", preference: "Bisexual", bio: "Smart and witty", imageNames: ["guy1", "guy3", "TestImage"])
        ]
    }
}
