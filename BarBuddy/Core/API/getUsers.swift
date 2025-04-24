//
//  getUsers.swift
//  BarBuddy
//
//  Updated 2025‑04‑16 – REST GET /users using Firebase idToken
//

import SwiftUI
import FirebaseAuth
import Foundation

// MARK: - Models
struct PostUser: Codable {
    let username: String
    let first_name: String
    let last_name: String
    let email: String
    let password: String
    let date_of_birth: String
    let hometown: String
    let job_or_university: String
    let favorite_drink: String
    let profile_pictures: [String]  // Changed to array of URLs
    let account_type: String
    let sexual_preference: String
    
    enum CodingKeys: String, CodingKey {
        case username
        case first_name
        case last_name
        case email
        case password
        case date_of_birth
        case hometown
        case job_or_university
        case favorite_drink
        case profile_pictures
        case account_type
        case sexual_preference
    }
    
    init(username: String, first_name: String, last_name: String, email: String, password: String,
         date_of_birth: String, hometown: String, job_or_university: String, favorite_drink: String,
         profile_pictures: [String] = [], account_type: String = "regular",
         sexual_preference: String = "straight") {
        self.username = username
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
        self.password = password
        self.date_of_birth = date_of_birth
        self.hometown = hometown
        self.job_or_university = job_or_university
        self.favorite_drink = favorite_drink
        self.profile_pictures = profile_pictures
        self.account_type = account_type
        self.sexual_preference = sexual_preference
    }
}

// MARK: - Network service for creating users
@MainActor
final class PostUserAPIService {
    static let shared = PostUserAPIService()
    private let baseURL = URL(string: "barbuddy-backend-148659891217.us-central1.run.app/api")!
    
    func create(user: PostUser) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw APIError.noToken
        }
        
        let idToken = try await currentUser.getIDToken()
        let endpoint = baseURL.appendingPathComponent("users/")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(user)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.transport(NSError(domain: "", code: -1))
        }
        
        switch httpResponse.statusCode {
        case 201:
            return
        case 400:
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.validation(errorResponse.detail)
            }
            throw APIError.validation("Invalid request data")
        case 401:
            throw APIError.unauthorized
        case 409:
            throw APIError.conflict("Username or email already exists")
        default:
            throw APIError.transport(NSError(domain: "", code: httpResponse.statusCode))
        }
    }
}

// MARK: - Error handling
enum APIError: LocalizedError {
    case noToken
    case transport(Error)
    case decoding(Error)
    case validation(String)
    case unauthorized
    case conflict(String)
    case networkError
    case notFound
    case serverError(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .noToken:
            return "No authentication token available"
        case .transport(let error):
            return "Network error: \(error.localizedDescription)"
        case .decoding(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .validation(let message):
            return "Validation error: \(message)"
        case .unauthorized:
            return "Authentication failed"
        case .conflict(let message):
            return "Conflict: \(message)"
        case .networkError:
            return "Network error"
        case .notFound:
            return "Resource not found"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Error response model
struct ErrorResponse: Codable {
    let detail: String
}

// MARK: - Model matching server response
struct GetUser: Codable, Identifiable, Hashable {
    let id: String  // Changed to String to match Firebase UID
    let username: String
    let first_name: String
    let last_name: String
    let email: String
    let date_of_birth: String
    let hometown: String
    let job_or_university: String
    let favorite_drink: String
    let location: Point?  // Made optional and proper type
    let profile_pictures: [String]?  // Changed to array of URLs
    let matches: [String]  // Changed to array
    let swipes: [String]   // Changed to array
    let vote_weight: Int
    let account_type: String
    let sexual_preference: String
    
    // Computed properties for convenience
    var fullName: String {
        "\(first_name) \(last_name)".trimmingCharacters(in: .whitespaces)
    }
    
    var mainProfilePicture: String? {
        profile_pictures?.first
    }
    
    struct Point: Codable, Hashable {
        let latitude: Double
        let longitude: Double
    }
}

// MARK: - Configuration
enum API {
    static let baseURL: URL = {
        #if DEBUG
        return URL(string: "https://dev.barbuddy-backend-148659891217.us-central1.run.app/api")!
        #else
        return URL(string: "https://barbuddy-backend-148659891217.us-central1.run.app/api")!
        #endif
    }()
    
    static let timeoutInterval: TimeInterval = 30
}

// MARK: - Network service
@MainActor
final class GetUserAPIService {
    static let shared = GetUserAPIService()
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 1.0
    
    private init() {}
    
    private func createRequest(_ path: String, method: String = "GET", body: Data? = nil) async throws -> URLRequest {
        guard let currentUser = Auth.auth().currentUser else {
            throw APIError.noToken
        }
        
        let idToken = try await currentUser.getIDToken()
        let endpoint = API.baseURL.appendingPathComponent(path)
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = method
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = API.timeoutInterval
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    /// GET /users – returns the full users list
    func fetchUsers() async throws -> [GetUser] {
        return try await withRetry {
            let request = try await createRequest("users")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError
            }
            
            switch httpResponse.statusCode {
            case 200:
                return try JSONDecoder().decode([GetUser].self, from: data)
            case 401:
                throw APIError.unauthorized
            case 404:
                throw APIError.notFound
            default:
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.detail)
                }
                throw APIError.unknown
            }
        }
    }
    
    /// Update user information
    func updateUserInfo(userInfo: [String: Any]) async throws {
        return try await withRetry {
            let jsonData = try JSONSerialization.data(withJSONObject: userInfo)
            let request = try await createRequest("users/update_user_info/", method: "POST", body: jsonData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError
            }
            
            switch httpResponse.statusCode {
            case 200:
                return
            case 401:
                throw APIError.unauthorized
            case 404:
                throw APIError.notFound
            default:
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.detail)
                }
                throw APIError.unknown
            }
        }
    }
    
    private func withRetry<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                return try await operation()
            } catch {
                lastError = error
                if attempt < maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? APIError.unknown
    }
}

// MARK: - ViewModel
@MainActor
final class UsersViewModel: ObservableObject {
    @Published var users: [GetUser] = []
    @Published var errorMessage = ""
    @Published var showingError = false
    @Published var isLoading = false
    
    func loadUsers() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            users = try await GetUserAPIService.shared.fetchUsers()
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            showingError = true
        } catch {
            errorMessage = "An unexpected error occurred"
            showingError = true
        }
    }
}

// MARK: - SwiftUI View
struct UsersListView: View {
    @StateObject private var vm = UsersViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if vm.isLoading {
                    ProgressView()
                } else {
                    List(vm.users) { user in
                        VStack(alignment: .leading) {
                            Text(user.fullName)
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                            if let location = user.location {
                                Text(location)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Users")
            .refreshable { await vm.loadUsers() }
            .onAppear { Task { await vm.loadUsers() } }
            .alert("Error",
                   isPresented: $vm.showingError,
                   actions: { Button("OK", role: .cancel) { vm.showingError = false } },
                   message: { Text(vm.errorMessage) })
        }
    }
}

// MARK: - Preview
extension GetUser {
    static let mock = GetUser(
        id: "user123",
        username: "user123",
        first_name: "Rob",
        last_name: "Smith",
        email: "mail@mail.com",
        date_of_birth: "1990-01-01",
        hometown: "Springfield",
        job_or_university: "Example University",
        favorite_drink: "Coffee",
        location: Point(latitude: 0.0, longitude: 0.0),
        profile_pictures: ["https://example.com/profile.jpg"],
        matches: [],
        swipes: [],
        vote_weight: 1,
        account_type: "regular",
        sexual_preference: "straight"
    )
}

struct UsersListView_Previews: PreviewProvider {
    static var previews: some View {
        UsersListView()
    }
}
