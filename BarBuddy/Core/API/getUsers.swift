//
//  getUsers.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/14/25.
//

import SwiftUI
import FirebaseFirestore


// MARK: - Model Definition
// The GetApp struct maps to your Firestore JSON structure.
// It conforms to Codable and Identifiable. The @DocumentID wrapper
// automatically maps the Firestore document ID.
struct GetApp: Codable, Identifiable {
    @DocumentID var id: String?              // Firestore document ID
    var username: String
    var first_name: String
    var last_name: String
    var email: String
    var password: String
    var date_of_birth: String              // Consider parsing this into a Date if needed
    var hometown: String
    var job_or_university: String
    var favorite_drink: String
    var location: String
    var profile_pictures: [String: String]?  // Adjust based on your storage format
    var matches: String
    var swipes: String
    var vote_weight: Int
    var account_type: String
}

// MARK: - ViewModel for Fetching GetApp Objects
class UsersViewModel: ObservableObject {
    // Notice that we use GetApp rather than User so the types match.
    @Published var Users = [GetApp]()
    private var db = Firestore.firestore()
    
    /// Fetches all user documents from the "users" collection.
    func fetchUsers() {
        db.collection("Users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }
            
            // Decode each document into a GetApp instance
            if let snapshot = snapshot {
                self.Users = snapshot.documents.compactMap { document in
                    try? document.data(as: GetApp.self)
                }
            }
        }
    }
}

// MARK: - SwiftUI View to Display GetApp Objects
struct ContentViewGet: View {
    @StateObject private var viewModel = UsersViewModel()
    
    var body: some View {
        NavigationView {
            // This initializer takes an array (no binding) since GetApp conforms to Identifiable
            List(viewModel.Users) { user in
                VStack(alignment: .leading) {
                    Text(user.username)
                        .font(.headline)
                    Text(user.email)
                        .font(.subheadline)
                }
            }
            .navigationTitle("Users")
            .onAppear {
                viewModel.fetchUsers()
            }
        }
    }
}

// MARK: - Preview Provider
struct ContentViewGet_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewGet()
    }
}
