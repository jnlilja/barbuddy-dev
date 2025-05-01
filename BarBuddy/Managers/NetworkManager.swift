//
//  NetworkManager.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/25/25.
//

import FirebaseAuth
import Foundation

@MainActor
final class NetworkManager {
    
    static let shared = NetworkManager()
    private let session: URLSession
    private let baseURL = ProcessInfo.processInfo.environment["BASE_URL"] ?? ""
    private let (encoder, decoder) = (JSONEncoder(), JSONDecoder())
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: Users
    /// GET /users – returns the full users list
    func fetchUsers() async throws -> [User] {
        let endpoint = baseURL + "users/"
        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        guard let idToken = try await Auth.auth().currentUser?.getIDToken()
        else { throw NetworkError.idTokenDecodingFailed }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(
            "Bearer \(idToken)",
            forHTTPHeaderField: "Authorization"
        )
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else {
                throw NetworkError.httpError
            }
            return try decoder.decode([User].self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
    
    func getUser(user: CreateUserRequest) async throws -> User {
        let endpoint = baseURL + "users/"
        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        guard let idToken = try await Auth.auth().currentUser?.getIDToken()
        else { throw NetworkError.idTokenDecodingFailed }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(
            "Bearer \(idToken)",
            forHTTPHeaderField: "Authorization"
        )
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let (data, response) = try await session.data(for: request)
            if let hhttpResponse = response as? HTTPURLResponse {
                print("getUser Status code: \(hhttpResponse.statusCode)")
            }
            return try decoder.decode(User.self, from: data)
        } catch {
            print("Data unsuccessfully decoded")
            throw NetworkError.decodingFailed
        }
    }
    
    func getUser(id: Int) async throws -> User {
        let endpoint = baseURL + "users/\(id)/"
        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        guard let idToken = try await Auth.auth().currentUser?.getIDToken()
        else { throw NetworkError.idTokenDecodingFailed }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(
            "Bearer \(idToken)",
            forHTTPHeaderField: "Authorization"
        )
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else { throw NetworkError.httpError }
            
            return try decoder.decode(User.self, from: data)
            
        } catch {
            print("Data unsuccessfully decoded")
            throw NetworkError.decodingFailed
        }
    }
    
    // MARK: - User Registration
    /// POST /users/register_user/ – registers a new user
    /// - Parameter user: The user information to register
    /// - Returns: The registered user from the server response
    /// - Throws: APIError or NetworkError if registration fails
    func postUser(user: CreateUserRequest) async throws -> User {
        let endpoint = baseURL + "users/register_user/"
        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let encodedData = try encoder.encode(user)
            request.httpBody = encodedData
            print("Request payload: \(String(data: encodedData, encoding: .utf8) ?? "No data")")
        } catch {
            print("Encoding failed: \(error)")
            throw APIError.encoding(error)
        }
        
        do {
            // Use a background task to prevent network timeout issues
            let (data, response) = try await session.data(for: request)
            
            // Log response data for debugging
            print("Response data: \(String(data: data, encoding: .utf8) ?? "No response data")")
            print("Data length: \(data.count) bytes")
            print("Raw data: \(data as NSData)")


            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            print("Status code: \(httpResponse.statusCode)")
            
            if !(200...299).contains(httpResponse.statusCode) {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("Server error: \(httpResponse.statusCode) - \(errorMessage)")
                throw NetworkError.httpError
            }
            
            // Try to decode the response
            do {
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(User.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    print("Decoding error details: \(decodingError)")
                }
                throw NetworkError.decodingFailed
            }
        } catch {
            print("Network request failed with error: \(error)")
            throw NetworkError.httpError
        }
    }
    
    // MARK: - Bar Hours
    
    func fetchBarHours() async throws -> [BarHours] {
        let endpoint = baseURL + "bars-hours/"
        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        guard let tokenID = try await Auth.auth().currentUser?.getIDToken() else {
            print("No token found")
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(tokenID)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            print("Fetch bar hours Code status: \(httpResponse.statusCode)")
            
            if !(200...299).contains(httpResponse.statusCode) {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("Server error: \(httpResponse.statusCode) - \(errorMessage)")
                throw NetworkError.httpError
            }
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([BarHours].self, from: data)
        } catch {
            print("Failed to decode bar hours data: \(error)")
            throw NetworkError.decodingFailed
        }
    }
    
    func fetchBarHours(for id: Int) async throws -> BarHours {
        let endpoint = baseURL + "bars-hours/\(id)/"
        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        guard let tokenID = try await Auth.auth().currentUser?.getIDToken() else {
            print("No token found")
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(tokenID)", forHTTPHeaderField: "Authorization")
        
        
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            print("Fetch bar hours Code status: \(httpResponse.statusCode)")
            
            if !(200...299).contains(httpResponse.statusCode){
                throw NetworkError.invalidResponse
            }
        do {
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(BarHours.self, from: data)
        } catch {
            print("Decoding failed: \(error)")
            throw NetworkError.decodingFailed
        }
    }
    
    func postBarHours(_ barHours: BarHours) async throws {
        let endpoint = baseURL + "bars-hours/"
        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        guard let tokenID = try await Auth.auth().currentUser?.getIDToken() else {
            print( "No token available")
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(tokenID)", forHTTPHeaderField: "Authorization")
        
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(barHours)
        
        do {
            let (_, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            if !(200...299).contains(httpResponse.statusCode) {
                print("Server error: \(httpResponse.statusCode)")
                throw NetworkError.httpError
            }
        }
    }
    
    func postBarHoursBulk(_ barHours: [BarHours]) async throws {
        let endpoint = baseURL + "bars-hours/bulk_update/"
        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        guard let tokenID = try await Auth.auth().currentUser?.getIDToken() else {
            print( "No token available")
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(tokenID)", forHTTPHeaderField: "Authorization")
        
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try encoder.encode(barHours)
        request.httpBody = jsonData
        print("Payload: \(String(data: jsonData, encoding: .utf8) ?? "No payload")")
    }
    
    func fetchBarHoursByBar() async throws -> [BarHours] {
        let endpoint = baseURL + "bars-hours/bar_bar/"
        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        guard let tokenID = try await Auth.auth().currentUser?.getIDToken() else {
            print("No user token")
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(tokenID)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            print("Failed to fetch bar hours: \(String(data: data, encoding: .utf8) ?? "No data returned")")
            throw NetworkError.invalidResponse
        }
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([BarHours].self, from: data)
    }
    
    func putBarHours(_ barHours: BarHours) async throws {
        let endpoint = baseURL + "bars-hours/\(barHours.id)/"
        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        guard let tokenID = try await Auth.auth().currentUser?.getIDToken() else {
            print("No user token")
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(tokenID)", forHTTPHeaderField: "Authorization")
        
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(barHours)
        
        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            print("Failed to update bar hours: \(String(data: data, encoding: .utf8) ?? "No data returned")")
            throw NetworkError.invalidResponse
        }
    }
    
    /// Deletes a bar hours entry by its ID
    /// - Parameter id: The ID of the bar hours entry to delete
    /// - Throws: APIError or NetworkError if deletion fails
    func deleteBarHours(for barHours: BarHours) async throws {
        let endpoint = baseURL + "bars-hours/\(barHours.id)/"
        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        
        guard let tokenID = try await Auth.auth().currentUser?.getIDToken() else {
            print("No user token")
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(tokenID)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            print("Delete bar hours status code: \(httpResponse.statusCode)")
            
            if !(200...299).contains(httpResponse.statusCode) {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("Failed to delete bar hours: \(errorMessage)")
                throw NetworkError.httpError
            }
            
            print("Successfully deleted bar hours with ID: \(barHours.id)")
        } catch {
            print("Delete request failed: \(error)")
            throw NetworkError.httpError
        }
    }
        
}
    
    
    
    
    
        
        //        // MARK: - Post User Profile Pictures
        //        private func postPictures(of user: User) async throws {
        //            try await withThrowingTaskGroup { group in
        //
        //                guard let pictures = user.profilePictures else { print("No pictures to upload"); return }
        //                guard let idToken = try await Auth.auth().currentUser?.getIDToken() else { throw APIError.noToken }
        //
        //                for picture in pictures {
        //                    group.addTask {
        //                        let endpoint = baseURL + "users/\(user.id)/upload_picture/\(picture)"
        //
        //                        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        //                        var request = URLRequest(url: url)
        //                        request.httpMethod = "POST"
        //                        request.setValue(" Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        //                        request.setValue("application/json", forHTTPHeaderField: "Accept")
        //                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //
        //                        let (data, response) = try await session.data(for: request)
        //                        if let hhttpResponse = response as? HTTPURLResponse {
        //                            print("postPicture Status code: \(hhttpResponse.statusCode)")
        //                        }
        //                        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else { throw NetworkError.httpError }
        //
        //                        do {
        //                            encoder.keyEncodingStrategy = .convertToSnakeCase
        //                            request.httpBody = try encoder.encode(picture)
        //                            print("Response data: \(String(data: data, encoding: .utf8) ?? "No response")")
        //                        } catch {
        //                            throw NetworkError.pictureDecodingFailed
        //                        }
        //                    }
        //                }
        //            }
        //        }
        
        //    private func putPrimaryPicture(of user: User) async throws {
        //        guard let primaryPicture = user.profilePictures?.first(where: { $0.isPrimary }) else { print("No primary picture to upload"); return }
        //        guard let idToken = try await Auth.auth().currentUser?.getIDToken() else { throw APIError.noToken }
        //        let endpoint = baseURL + "users/\(user.id!)/set_primary_picture/\(primaryPicture.url)"
        //
        //        guard let url = URL(string: endpoint) else { throw APIError.badURL }
        //        var request = URLRequest(url: url)
        //        let (data, response) = try await session.data(for: request)
        //        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else { throw NetworkError.httpError }
        //
        //        request.httpMethod = "PUT"
        //        request.setValue(""" Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        //        request.setValue("application/json", forHTTPHeaderField: "Accept")
        //        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //
        //        do {
        //            encoder.keyEncodingStrategy = .convertToSnakeCase
        //            request.httpBody = try encoder.encode(primaryPicture.url)
        //            print("Response data: \(String(data: data, encoding: .utf8) ?? "No response")")
        //        } catch {
        //            throw NetworkError.primaryPictureEncodingFailed
        //        }
        //    }

