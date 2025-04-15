//
//  postUsers.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/14/25.
//  Updated to accept dynamic user data for sign-up.
//

import SwiftUI
import FirebaseFirestore

// MARK: - Model Definition for Posting a User
struct PostUser: Codable {
    var username: String
    var first_name: String
    var last_name: String
    var email: String
    var password: String
    var date_of_birth: String  // Consider using Date for type safety in production.
    var hometown: String
    var job_or_university: String
    var favorite_drink: String
    var profile_pictures: [String: String]?  // Example uses dictionary for profile pictures.
    var account_type: String
}

// MARK: - ViewModel for Posting a User
class PostUserViewModel: ObservableObject {
    private var db = Firestore.firestore()
    
    /// Posts a new user to the "Users" collection using the provided PostUser data.
    func postUser(newUser: PostUser) {
        do {
            // Add the new document to the "Users" collection. Firestore will generate a unique document ID.
            let _ = try db.collection("Users").addDocument(from: newUser)
            print("User successfully posted!")
        } catch {
            print("Error posting user: \(error.localizedDescription)")
        }
    }
}

// MARK: - SwiftUI View for Posting a User (Demo)
struct ContentViewPost: View {
    @StateObject private var viewModel = PostUserViewModel()
    
    // For demonstration purposes, create a demo user.
    // In your actual app, you would gather this information from a sign-up form.
    let demoUser = PostUser(
        username: "j_X@FT+0eTcen3-D2845sfa5f_5kWnx",
        first_name: "John",
        last_name: "Doe",
        email: "user@example.com",
        password: "Password123!",
        date_of_birth: "2025-04-14",
        hometown: "Hometown",
        job_or_university: "University",
        favorite_drink: "Coffee",
        profile_pictures: [:],
        account_type: "regular"
    )
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create a New User")
                    .font(.title)
                
                Button(action: {
                    // Call the updated API method with demoUser data.
                    viewModel.postUser(newUser: demoUser)
                }) {
                    Text("Post User")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .navigationTitle("Post User")
        }
    }
}

// MARK: - Preview Provider
struct ContentViewPost_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewPost()
    }
}
