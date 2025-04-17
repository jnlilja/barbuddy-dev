//
//  postUsers.swift
//  BarBuddy
//
//  Fixed 2025‑04‑16 – adds completion‑style updateLocation(), async wrapper, and
//  removes access to the private baseURL of GetUserAPIService from another file.
//

import SwiftUI
@preconcurrency import FirebaseAuth

// MARK: - Data model sent to backend
struct PostUser: Codable {
    var username: String
    var first_name: String
    var last_name: String
    var email: String
    var password: String
    var date_of_birth: String
    var hometown: String
    var job_or_university: String
    var favorite_drink: String
    var profile_pictures: [String: String]?
    var account_type: String
    var sexual_preference: String
}

// MARK: - Networking service
@MainActor
final class PostUserAPIService {
    static let shared = PostUserAPIService()
    private let baseURL = URL(string: "https://YOUR_API_BASE_URL")!   // ← Edit

    /// POST /users – create a profile document in your backend
    func create(user: PostUser,
                completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return completion(.failure(.noToken))
        }

        currentUser.getIDToken { idToken, err in
            if let err = err { return completion(.failure(.transport(err))) }
            guard let idToken = idToken else { return completion(.failure(.noToken)) }

            var request = URLRequest(url: self.baseURL.appendingPathComponent("users"))
            request.httpMethod = "POST"
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do { request.httpBody = try JSONEncoder().encode(user) }
            catch { return completion(.failure(.encoding(error))) }

            URLSession.shared.dataTask(with: request) { _, _, error in
                if let error = error {
                    completion(.failure(.transport(error)))
                } else {
                    completion(.success(()))
                }
            }.resume()
        }
    }

    /// completion‑based location update (needed for async wrapper)
    func updateLocation(lat: Double,
                        lon: Double,
                        completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return completion(.failure(.noToken))
        }

        currentUser.getIDToken { idTok, err in
            if let err = err { return completion(.failure(.transport(err))) }
            guard let idTok = idTok else { return completion(.failure(.noToken)) }

            var req = URLRequest(url: self.baseURL.appendingPathComponent("users/update_location"))
            req.httpMethod = "POST"
            req.setValue("Bearer \(idTok)", forHTTPHeaderField: "Authorization")
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: Any] = ["latitude": lat, "longitude": lon]
            do { req.httpBody = try JSONSerialization.data(withJSONObject: body) }
            catch { return completion(.failure(.encoding(error))) }

            URLSession.shared.dataTask(with: req) { _, _, error in
                if let error = error {
                    completion(.failure(.transport(error)))
                } else {
                    completion(.success(()))
                }
            }.resume()
        }
    }
}

// MARK: - Async helpers
extension PostUserAPIService {
    /// POST /users/update_location/ – async variant
    func updateLocation(lat: Double, lon: Double) async throws {
        try await withCheckedThrowingContinuation { cont in
            self.updateLocation(lat: lat, lon: lon) { result in
                cont.resume(with: result)
            }
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

// MARK: - ViewModel
@MainActor
class PostUserViewModel: ObservableObject {
    @Published var statusMessage = ""

    func post(user: PostUser) {
        PostUserAPIService.shared.create(user: user) { [weak self] result in
            switch result {
            case .success:
                self?.statusMessage = "✅ User successfully posted."
            case .failure(let err):
                self?.statusMessage = err.localizedDescription
            }
        }
    }
}

