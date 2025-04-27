//
//  NetworkManager.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/25/25.
//

import Foundation
import FirebaseAuth

@MainActor
final class NetworkManager {
    
    static let shared = NetworkManager()
    private let session: URLSession
    private let baseURL = ProcessInfo.processInfo.environment["BASE_URL"] ?? "http://localhost:8080/"
    private let (encoder, decoder) = (JSONEncoder(), JSONDecoder())

    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// GET /users – returns the full users list
    func fetchUsers() async throws -> [User] {
        let endpoint = baseURL + "users"
        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        guard let idToken = try await Auth.auth().currentUser?.getIDToken() else { throw NetworkError.idTokenDecodingFailed }
        var request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.httpError
        }
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([User].self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
    
    func getUser(user: User) async throws -> User {
        let endpoint = baseURL + "users/\(String(describing: user.id))"
        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        guard let idToken = try await Auth.auth().currentUser?.getIDToken() else { throw NetworkError.idTokenDecodingFailed }
        var request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw NetworkError.httpError }
        
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(User.self, from: data)
        } catch {
            print("Data unsuccessfully decoded")
            throw NetworkError.decodingFailed
        }
    }
    
    func getUser(uid: String) async throws -> User {
        let endpoint = baseURL + "users/\(uid)"
        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        guard let idToken = try await Auth.auth().currentUser?.getIDToken() else { throw NetworkError.idTokenDecodingFailed }
        var request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw NetworkError.httpError }
        
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(User.self, from: data)
        } catch {
            print("Data unsuccessfully decoded")
            throw NetworkError.decodingFailed
        }
    }
    
    func postUser(user: User) async throws {
        let endpoint = baseURL + "users"
        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        guard let idToken = try await Auth.auth().currentUser?.getIDToken() else { throw APIError.noToken }
        var request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        if let hhttpResponse = response as? HTTPURLResponse {
            print("Status code: \(hhttpResponse.statusCode)")
        }
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw NetworkError.httpError }
        
        request.httpMethod = "POST"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try encoder.encode(user)
            print("Response data: \(String(data: data, encoding: .utf8) ?? "No response")")
            
            try await postPictures(of: user)
            
            
        } catch NetworkError.pictureDecodingFailed {
            print("Could not decode picture data")
        } catch {
            throw APIError.encoding(error)
        }
    }
    
    private func postPictures(of user: User) async throws {
        guard let pictures = user.profilePictures else { print("No pictures to upload"); return }
        guard let idToken = try await Auth.auth().currentUser?.getIDToken() else { throw APIError.noToken }
        
        for picture in pictures where !picture.isPrimary {
            let endpoint = baseURL + "users/\(user.id!)/upload_picture/\(picture.url)"
            
            guard let url = URL(string: endpoint) else { throw APIError.badURL }
            var request = URLRequest(url: url)
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw NetworkError.httpError }
            
            request.httpMethod = "POST"
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                encoder.keyEncodingStrategy = .convertToSnakeCase
                request.httpBody = try encoder.encode(picture.url)
                print("Response data: \(String(data: data, encoding: .utf8) ?? "No response")")
            } catch {
                throw NetworkError.pictureDecodingFailed
            }
        }
    }
    
    private func putPrimaryPicture(of user: User) async throws {
        guard let primaryPicture = user.profilePictures?.first(where: { $0.isPrimary }) else { print("No primary picture to upload"); return }
        guard let idToken = try await Auth.auth().currentUser?.getIDToken() else { throw APIError.noToken }
        let endpoint = baseURL + "users/\(user.id!)/set_primary_picture/\(primaryPicture.url)"
        
        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        var request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw NetworkError.httpError }
        
        request.httpMethod = "PUT"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try encoder.encode(primaryPicture.url)
            print("Response data: \(String(data: data, encoding: .utf8) ?? "No response")")
        } catch {
            throw NetworkError.primaryPictureEncodingFailed
        }
    }
}
