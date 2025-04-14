//
//  postUsers.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/14/25.
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
    var date_of_birth: String  // You might consider using a Date type if preferred
    var hometown: String
    var job_or_university: String
    var favorite_drink: String
    var profile_pictures: [String: String]?  // This example uses a dictionary
    var account_type: String
}

// MARK: - ViewModel for Posting a User
class PostUserViewModel: ObservableObject {
    private var db = Firestore.firestore()
    
    /// Posts a new user to the "Users" collection with the given JSON data.
    func postUser() {
        // Create a new PostUser using the supplied JSON values
        let newUser = PostUser(
            username: "j_X@FT+0eTcen3-D2845sfa5f_5kWnx",
            first_name: "string",
            last_name: "string",
            email: "user@example.com",
            password: "string",
            date_of_birth: "2025-04-14",
            hometown: "string",
            job_or_university: "string",
            favorite_drink: "string",
            profile_pictures: [:],
            account_type: "regular"
        )
        
        do {
            // Add the new document to the "Users" collection. Firestore will generate a unique document ID.
            let _ = try db.collection("Users").addDocument(from: newUser)
            print("User successfully posted!")
        } catch {
            print("Error posting user: \(error.localizedDescription)")
        }
    }
}

// MARK: - SwiftUI View for Posting a User
struct ContentViewPost: View {
    @StateObject private var viewModel = PostUserViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create a New User")
                    .font(.title)
                
                Button(action: {
                    viewModel.postUser()
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
