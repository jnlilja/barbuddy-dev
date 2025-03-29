//
//  FetchViewModel.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/25/25.
//

import Foundation

class NetworkManager {
    
    
    
    func getUser() async throws {
        let endpoint = "https:/localhost:8000/api"
        guard let url = URL(string: endpoint) else {
            print("Failed to create URL")
            return
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Failed to connect to server")
            return
        }
        
        
    }
}
