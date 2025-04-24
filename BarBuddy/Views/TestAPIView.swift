import SwiftUI
import FirebaseAuth

struct TestAPIView: View {
    @State private var users: [GetUser] = []
    @State private var error: String?
    @State private var isLoading = false
    @State private var isSignedIn = false
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            if !isSignedIn {
                // Sign In Form
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Sign In") {
                        signIn()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            } else {
                // User List
                if isLoading {
                    ProgressView()
                } else if let error = error {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else {
                    List(users) { user in
                        VStack(alignment: .leading) {
                            Text(user.fullName)
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                            if let picture = user.mainProfilePicture {
                                AsyncImage(url: URL(string: picture)) { image in
                                    image.resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(height: 100)
                            }
                        }
                    }
                }
                
                Button("Test API") {
                    testAPI()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Sign Out") {
                    signOut()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            checkAuthState()
        }
    }
    
    private func checkAuthState() {
        if Auth.auth().currentUser != nil {
            isSignedIn = true
        }
    }
    
    private func signIn() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                print("Signed in with user: \(result.user.uid)")
                isSignedIn = true
                
                // After signing in, create/update user in backend
                let user = PostUser(
                    username: result.user.displayName ?? "user_\(result.user.uid.prefix(8))",
                    first_name: result.user.displayName?.components(separatedBy: " ").first ?? "",
                    last_name: result.user.displayName?.components(separatedBy: " ").last ?? "",
                    email: result.user.email ?? "",
                    password: password,
                    date_of_birth: "2000-01-01",
                    hometown: "Unknown",
                    job_or_university: "Unknown",
                    favorite_drink: "Unknown"
                )
                
                try await PostUserAPIService.shared.create(user: user)
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            isSignedIn = false
            users = []
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func testAPI() {
        isLoading = true
        error = nil
        
        Task {
            do {
                users = try await GetUserAPIService.shared.fetchUsers()
            } catch let apiError as APIError {
                error = apiError.errorDescription
            } catch {
                error = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    TestAPIView()
} 