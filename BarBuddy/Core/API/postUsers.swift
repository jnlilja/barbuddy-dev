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
    private let baseURL = URL(string: "http://127.0.0.1:8000/api/")!   // Added trailing slash

    /// POST /users – create a profile document in your backend
    func create(user: PostUser, completion: @escaping @Sendable (Result<Void, APIError>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("❌ No current user found")
            return completion(.failure(.noToken))
        }

        print("👤 Current user UID:", currentUser.uid)
        print("👤 Current user email:", currentUser.email ?? "no email")

        currentUser.getIDToken { idToken, err in
            if let err = err {
                print("❌ Error getting ID token:", err.localizedDescription)
                return completion(.failure(.transport(err)))
            }
            guard let idToken = idToken else {
                print("❌ No token received")
                return completion(.failure(.noToken))
            }

            print("✅ Successfully got Firebase token")
            print("🔑 Token length:", idToken.count)
            print("🔑 Token first 20 chars:", String(idToken.prefix(20)))

            var request = URLRequest(url: self.baseURL.appendingPathComponent("users/"))  // Added trailing slash
            request.httpMethod = "POST"  // Changed from PUT to POST
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            // Log all headers for debugging
            print("📝 Request headers:", request.allHTTPHeaderFields ?? [:])
            print("🌐 Request URL:", request.url?.absoluteString ?? "unknown")

            do {
                request.httpBody = try JSONEncoder().encode(user)
                print("📦 Request body:", String(data: request.httpBody!, encoding: .utf8) ?? "unknown")
            } catch {
                print("❌ Encoding error:", error.localizedDescription)
                return completion(.failure(.encoding(error)))
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Network error:", error.localizedDescription)
                    completion(.failure(.transport(error)))
                    return
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
                    
                    if !(200...299).contains(httpResponse.statusCode) {
                        print("❌ Server error - Status code:", httpResponse.statusCode)
                        if let data = data, let errorString = String(data: data, encoding: .utf8) {
                            print("❌ Server error message:", errorString)
                        }
                        return completion(.failure(.transport(URLError(.badServerResponse))))
                    }
                }

                completion(.success(()))
            }.resume()
        }
    }

    /// completion‑based location update (needed for async wrapper)
    func updateLocation(lat: Double,
                        lon: Double,
                        completion: @escaping @Sendable (Result<Void, APIError>) -> Void) {
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
                let base = URL(string: "http://127.0.0.1:8000/api")!  // ← keep in sync
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
            Task { @MainActor in
                switch result {
                case .success:
                    self?.statusMessage = "✅ User successfully posted."
                case .failure(let err):
                    self?.statusMessage = err.localizedDescription
                }
            }
        }
    }
}

