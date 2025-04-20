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
    var email: String
    var password: String
    var date_of_birth: String
    var hometown: String
    var job_or_university: String
    var favorite_drink: String
    var location: String
    var profile_pictures: [String: String]?
    var matches: String
    var swipes: String
    var vote_weight: Int
    var account_type: String
    var sexual_preference: String
}

// MARK: - Network service
@MainActor
final class GetUserAPIService {
    static let shared = GetUserAPIService()
    private let baseURL = URL(string: "https://YOUR_API_BASE_URL")!   // ← Replace

    /// GET /users – returns the full users list
    func fetchUsers(completion: @escaping (Result<[GetUser], APIError>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return completion(.failure(.noToken))
        }

        currentUser.getIDToken { idToken, err in
            if let err = err { return completion(.failure(.transport(err))) }
            guard let idToken = idToken else { return completion(.failure(.noToken)) }

            let endpoint = self.baseURL.appendingPathComponent("users")
            var request  = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error { return completion(.failure(.transport(error))) }
                guard let data = data else { return completion(.success([])) }

                do {
                    let users = try JSONDecoder().decode([GetUser].self, from: data)
                    completion(.success(users))
                } catch {
                    completion(.failure(.decoding(error)))
                }
            }.resume()
        }
    }
}
// MARK: - Async/Await convenience
extension GetUserAPIService {
    /// Async wrapper around the callback‑based fetchUsers.
    func fetchUsers() async throws -> [GetUser] {
        try await withCheckedThrowingContinuation { continuation in
            self.fetchUsers { result in
                continuation.resume(with: result)
            }
        }
    }
}


// MARK: - ViewModel
@MainActor
final class UsersViewModel: ObservableObject {
    @Published var users: [GetUser] = []
    @Published var errorMessage = ""
    @Published var showingError = false

    func loadUsers() {
        GetUserAPIService.shared.fetchUsers { [weak self] result in
            switch result {
            case .success(let list):
                self?.users = list
            case .failure(let err):
                self?.errorMessage = err.localizedDescription
                self?.showingError = true
            }
        }
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
                    Text(user.email).font(.subheadline)
                }
            }
            .navigationTitle("Users")
            .refreshable { vm.loadUsers() }
            .onAppear      { vm.loadUsers() }
            .alert("Error",
                   isPresented: $vm.showingError,
                   actions: { Button("OK", role: .cancel) { vm.showingError = false } },
                   message:  { Text(vm.errorMessage) })
        }
    }
}

extension GetUser {
    static let MOCK_DATA = GetUser(id: 0, username: "Test User", first_name: "Andrew", last_name: "Betancourt", email: "mail@mail.com", password: "", date_of_birth: "", hometown: "", job_or_university: "", favorite_drink: "", location: "Hideaway", matches: "", swipes: "", vote_weight: 1, account_type: "", sexual_preference: "")

}

struct ContentViewGet_Previews: PreviewProvider {
    static var previews: some View { ContentViewGet() }
}
