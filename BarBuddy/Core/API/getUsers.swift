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
    private let baseURL = URL(string: "http://127.0.0.1:8000/api/")!
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true
        config.httpShouldUsePipelining = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil  // Disable caching to prevent multiple requests
        self.session = URLSession(configuration: config)
    }

    private func createRequest(url: URL, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        // Set consistent headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("📝 Created request with headers:", request.allHTTPHeaderFields ?? [:])
        return request
    }

    /// GET /users – returns the full users list
    func fetchUsers(completion: @escaping @Sendable (Result<[GetUser], APIError>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("❌ No current user found")
            return completion(.failure(.noToken))
        }
        
        print("👤 Current user UID:", currentUser.uid)
        print("👤 Current user email:", currentUser.email ?? "no email")

        currentUser.getIDToken { [weak self] token, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error getting ID token:", error.localizedDescription)
                return completion(.failure(.transport(error)))
            }
            
            guard let token = token else {
                print("❌ No token received")
                return completion(.failure(.noToken))
            }

            print("✅ Successfully got Firebase token")
            print("🔑 Token length:", token.count)
            print("🔑 Token first 20 chars:", String(token.prefix(20)))

            let endpoint = self.baseURL.appendingPathComponent("users/")
            let request = self.createRequest(url: endpoint, token: token)
            print("🌐 Request URL:", request.url?.absoluteString ?? "unknown")

            let task = self.session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Network error:", error.localizedDescription)
                    return completion(.failure(.transport(error)))
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Response status code:", httpResponse.statusCode)
                    print("📡 Response headers:", httpResponse.allHeaderFields)
                    
                    if httpResponse.statusCode == 401 {
                        print("❌ Unauthorized - Token may be invalid")
                        if let data = data, let errorString = String(data: data, encoding: .utf8) {
                            print("❌ Server error message:", errorString)
                        }
                        return completion(.failure(.transport(URLError(.userAuthenticationRequired))))
                    }
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    return completion(.success([]))
                }

                do {
                    let users = try JSONDecoder().decode([GetUser].self, from: data)
                    print("✅ Successfully decoded \(users.count) users")
                    completion(.success(users))
                } catch {
                    print("❌ Decoding error:", error.localizedDescription)
                    if let errorString = String(data: data, encoding: .utf8) {
                        print("❌ Raw response:", errorString)
                    }
                    completion(.failure(.decoding(error)))
                }
            }
            
            task.resume()
        }
    }

    /// GET /users?email=... – returns a single user by email
    func fetchUserByEmail(email: String, completion: @escaping @Sendable (Result<GetUser?, APIError>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("❌ No current user found")
            return completion(.failure(.noToken))
        }
        
        print("👤 Current user UID:", currentUser.uid)
        print("👤 Current user email:", currentUser.email ?? "no email")

        currentUser.getIDToken { [weak self] token, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error getting ID token:", error.localizedDescription)
                return completion(.failure(.transport(error)))
            }
            
            guard let token = token else {
                print("❌ No token received")
                return completion(.failure(.noToken))
            }

            print("✅ Successfully got Firebase token")
            print("🔑 Token length:", token.count)
            print("🔑 Token first 20 chars:", String(token.prefix(20)))

            // Construct URL with trailing slash
            let endpoint = self.baseURL.appendingPathComponent("users/")
            var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: true)!
            components.queryItems = [URLQueryItem(name: "email", value: email)]
            
            guard let url = components.url else {
                print("❌ Invalid URL")
                return completion(.failure(.transport(URLError(.badURL))))
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            print("📝 Request headers:", request.allHTTPHeaderFields ?? [:])
            print("🌐 Request URL:", request.url?.absoluteString ?? "unknown")

            let task = self.session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Network error:", error.localizedDescription)
                    return completion(.failure(.transport(error)))
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Response status code:", httpResponse.statusCode)
                    print("📡 Response headers:", httpResponse.allHeaderFields)
                    
                    if httpResponse.statusCode == 401 {
                        print("❌ Unauthorized - Token may be invalid")
                        if let data = data, let errorString = String(data: data, encoding: .utf8) {
                            print("❌ Server error message:", errorString)
                        }
                        return completion(.failure(.transport(URLError(.userAuthenticationRequired))))
                    }
                    
                    if httpResponse.statusCode == 403 {
                        print("❌ Forbidden - Authorization header may be missing")
                        if let data = data, let errorString = String(data: data, encoding: .utf8) {
                            print("❌ Server error message:", errorString)
                        }
                        return completion(.failure(.transport(URLError(.userAuthenticationRequired))))
                    }
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    return completion(.success(nil))
                }

                do {
                    let users = try JSONDecoder().decode([GetUser].self, from: data)
                    print("✅ Successfully decoded \(users.count) users")
                    completion(.success(users.first))
                } catch {
                    print("❌ Decoding error:", error.localizedDescription)
                    if let errorString = String(data: data, encoding: .utf8) {
                        print("❌ Raw response:", errorString)
                    }
                    completion(.failure(.decoding(error)))
                }
            }
            
            task.resume()
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

    /// Async wrapper around the callback‑based fetchUserByEmail.
    func fetchUserByEmail(email: String) async throws -> GetUser? {
        try await withCheckedThrowingContinuation { continuation in
            self.fetchUserByEmail(email: email) { result in
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
            Task { @MainActor in
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
    static let MOCK_DATA = GetUser(id: 0, username: "user123", first_name: "Rob", last_name: "Smith", email: "mail@mail.com", password: "", date_of_birth: "", hometown: "", job_or_university: "", favorite_drink: "", location: "Hideaway", matches: "", swipes: "", vote_weight: 1, account_type: "", sexual_preference: "")

}

struct ContentViewGet_Previews: PreviewProvider {
    static var previews: some View { ContentViewGet() }
}
