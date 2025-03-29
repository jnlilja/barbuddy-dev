//
//  FetchViewModel.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/25/25.
//

import Foundation

@MainActor
final class NetworkManager {
    
    static let shared = NetworkManager()
    private let session: URLSession
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    //TODO: Make network calls
    
    func getUser(id: Int) async throws -> User {
        let endpoint = "https:/localhost:8000/api/users/{\(id)}"
        guard let url = URL(string: endpoint) else { throw NetworkError.invalidURL }
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw NetworkError.invalidResponse }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(User.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
