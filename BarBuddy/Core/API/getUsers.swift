//
//  getUsers.swift
//  BarBuddy
//
//  Updated 2025‑04‑16 – REST GET /users using Firebase idToken
//

import SwiftUI
import FirebaseAuth

// MARK: - Model matching server response
struct GetUser: Codable, Identifiable, Hashable {
    var id: Int
    var username: String
    var first_name: String
    var last_name: String
    var date_of_birth: String?
    var email: String?
    var password: String?
    var hometown: String?
    var job_or_university: String?
    var favorite_drink: String?
    var location: String?
    var profile_pictures: [String] = []
    var matches: [String] = []
    var swipes: [String] = []
    var vote_weight: Int = 0
    var account_type: String = ""
    var sexual_preference: String?
}

// MARK: - Network service
@MainActor
final class GetUserAPIService {
    
    static let shared = GetUserAPIService()
    private let baseURL = URL(string: "https://barbuddy-backend-148659891217.us-central1.run.app/api")!   // ← Replace
    
    func getUser() async -> Result<GetUser, APIError> {
        guard let currentUser = Auth.auth().currentUser else { return .failure(.noUser) }
        let userId = currentUser.uid
        do {
            guard let url = URL(string: "https://barbuddy-backend-148659891217.us-central1.run.app/api/users/\(userId)/") else {
                return .failure(.badURL)
            }
            let idToken = try await currentUser.getIDToken()
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("json string: \(jsonString)")
            }
            
            if let response = response as? HTTPURLResponse {
                let statusCode = response.statusCode
                if statusCode > 400 {
                    print("bad request")
                    return .failure(.badRequest)
                }
                if statusCode > 500 {
                    print("internal server error")
                    return .failure(.serverError)
                }
            }
            do {
                let user = try JSONDecoder().decode(GetUser.self, from: data)
                return .success(user)
            } catch(let error) {
                print(error.localizedDescription)
                return .failure(.badURL)
            }
        } catch {
            return .failure(.badRequest)
        }
    }

    /// GET /users – returns the full users list
    func fetchUsers() async -> Result<[GetUser], APIError> {
        guard let currentUser = Auth.auth().currentUser else {
            return .failure(.noToken)
        }
        do {
            let idToken = try await currentUser.getIDToken()
            guard let url = URL(string: "https://barbuddy-backend-148659891217.us-central1.run.app/api/users/") else {
                return .failure(.badURL)
            }
            let endpoint = url
            var request  = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonData = String(data: data, encoding: .utf8) {
                print("messages json \(jsonData)")
            }
            let users = try JSONDecoder().decode([GetUser].self, from: data)
            return .success(users)
        } catch {
            return .failure(.decoding(error))
        }
    }
    
}

extension GetUserAPIService {
    
    /// GET /users/{id}/ – async helper to fetch a single user record by id
    func fetchUser(id: Int) async throws -> GetUser {
        try await withCheckedThrowingContinuation { cont in
            guard let holder = Auth.auth().currentUser else {
                return cont.resume(throwing: APIError.noToken)
            }
            holder.getIDToken { tok, err in
                if let err = err { return cont.resume(throwing: APIError.transport(err)) }
                guard let tok = tok else { return cont.resume(throwing: APIError.noToken) }

                // Build endpoint locally (cannot access private baseURL)
                let base = URL(string: "https://YOUR_API_BASE_URL")!  // ← keep in sync
                let url  = base.appendingPathComponent("users").appendingPathComponent(String(id))

                var req = URLRequest(url: url)
                req.setValue("Bearer \(tok)", forHTTPHeaderField: "Authorization")

                URLSession.shared.dataTask(with: req) { data, _, error in
                    if let error = error {
                        return cont.resume(throwing: APIError.transport(error))
                    }
                    guard let data = data else {
                        return cont.resume(throwing: APIError.badURL)
                    }
                    do {
                        let user = try JSONDecoder().decode(GetUser.self, from: data)
                        cont.resume(returning: user)
                    } catch {
                        cont.resume(throwing: APIError.decoding(error))
                    }
                }.resume()
            }
        }
    }
}

// MARK: - Async/Await convenience
//extension GetUserAPIService {
//    /// Async wrapper around the callback‑based fetchUsers.
//    func fetchUsers() async throws -> [GetUser] {
//        try await withCheckedThrowingContinuation { continuation in
//            self.fetchUsers { result in
//                continuation.resume(with: result)
//            }
//        }
//    }
//}


// MARK: - ViewModel
@MainActor
final class UsersViewModel: ObservableObject {
    @Published var users: [GetUser] = []
    @Published var errorMessage = ""
    @Published var showingError = false

    func loadUsers() async {
        
        let result = await GetUserAPIService.shared.fetchUsers()
        switch result {
        case .success(let success):
            print("did find users in messages")
            self.users = success
        case .failure(_):
            errorMessage = "Failed to get users"
        }
        
        
//        GetUserAPIService.shared.fetchUsers { [weak self] result in
//            Task { @MainActor in
//                switch result {
//                case .success(let list):
//                    print("messages did find success")
//                    self?.users = list
//                case .failure(let err):
//                    self?.errorMessage = err.localizedDescription
//                    self?.showingError = true
//                }
//            }
//        }
    }
}

// MARK: - SwiftUI View
struct ContentViewGet: View {
    @StateObject private var vm = UsersViewModel()

    var body: some View {
        NavigationView {
            List(vm.users) { user in
                VStack(alignment: .leading) {
                    Text(user.username).font(.headline)
                    Text(user.email ?? "No email provided").font(.subheadline)
                }
            }
            .navigationTitle("Users")
            .task {
                await vm.loadUsers()
            }
            .alert("Error",
                   isPresented: $vm.showingError,
                   actions: { Button("OK", role: .cancel) { vm.showingError = false } },
                   message:  { Text(vm.errorMessage) })
        }
    }
}

extension GetUser {
    static let MOCK_DATA = GetUser(id: 0, username: "user123", first_name: "Rob", last_name: "Smith", date_of_birth: "", email: "mail@mail.com", password: "", hometown: "", job_or_university: "", favorite_drink: "", location: "Hideaway", matches: [], swipes: [], vote_weight: 1, account_type: "", sexual_preference: "")

}

struct ContentViewGet_Previews: PreviewProvider {
    static var previews: some View { ContentViewGet() }
}
