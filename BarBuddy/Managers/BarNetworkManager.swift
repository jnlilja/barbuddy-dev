//
//  BarNetworkManager.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/18/25.
//  Updated — make models Sendable
//

import Foundation
import FirebaseAuth

actor BarNetworkManager: NetworkTestable {
    static let shared = BarNetworkManager()
    private let session: URLSession
    private let baseURL: String
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let timeStampDecoder: JSONDecoder
    
    private let voteCacheExpiration: TimeInterval = 300 // 5 minutes
    private let barHoursCacheExpiration: TimeInterval = 3600 // 1 hour
    private let barStatusCache: TimeInterval = 180 // 3 minutes
                
    internal init(session: URLSession = .shared) {
        self.session = session
        self.baseURL = AppConfig.baseURL
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder.timeOnly
        self.timeStampDecoder = JSONDecoder.microseconds.copy()
        
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    // MARK: Bar Vote
    
    // GET /bar-votes/summary/
    func fetchAllVotes() async throws -> [BarVote] {
        let endpoint = baseURL + "bar-votes/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
        return try decoder.decode([BarVote].self, from: data)
    }
    
    // POST /bar-votes/
    func submitVote(vote: BarVote) async throws {
        let endpoint = baseURL + "bar-votes/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try encoder.encode(vote)
        let (_, response) = try await session.data(for: request)
        
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
    }
    
    func fetchBarVote(for voteID: Int) async throws -> BarVote {
        let endpoint = baseURL + "bar-votes/\(voteID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw APIError.statusCode(httpResponse.statusCode)
        }
        
        return try decoder.decode(BarVote.self, from: data)
    }
    
    func putBarVote(voteID: Int) async throws {
        let endpoint = baseURL + "bar-votes/\(voteID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
    }
    
    func patchBarVote(voteID: Int) async throws {
        let endpoint = baseURL + "bar-votes/\(voteID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
    }
    
    func deleteBarVote(voteID: Int) async throws {
        let endpoint = baseURL + "bar-votes/\(voteID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
            throw APIError.statusCode(response.statusCode)
        }
    }
    
    // MARK: Bar Hours
    
    func postBarHours(hours: BarHours) async throws -> BarHours {
        let endpoint = baseURL + "bar-hours/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try encoder.encode(hours)
        
        let (data, response) = try await session.data(for: request)
        
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
        
        return try decoder.decode(BarHours.self, from: data)
    }
    
    func fetchBarHours(for barHoursId: Int) async throws -> BarHours {
        let endpoint = baseURL + "bar-hours/\(barHoursId)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
                throw APIError.noToken
            }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        if let http = response as? HTTPURLResponse,
                  !(200...299).contains(http.statusCode) {
                throw APIError.statusCode(http.statusCode)
            }
        
        return try decoder.decode(BarHours.self, from: data)
    }
    
    func fetchAllBarHours() async throws -> [BarHours] {
        let endpoint = baseURL + "bar-hours/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.cachePolicy = .returnCacheDataElseLoad
        
        // Check if we have a cached response first and if it's still valid
        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let cacheDate = UserDefaults.standard.object(forKey: "barHours_cache_timestamp") as? Date {

            let isExpired = Date().timeIntervalSince(cacheDate) > barHoursCacheExpiration
            if !isExpired {
                #if DEBUG
                print("Using cached bar hours data (valid)")
                #endif
                return try self.decoder.decode([BarHours].self, from: cachedResponse.data)
            } else {
                #if DEBUG
                print("Cache expired. Fetching new bar hours data.")
                #endif
                URLCache.shared.removeCachedResponse(for: request)
                UserDefaults.standard.removeObject(forKey: "barHours_cache_timestamp")
            }
        }
        
        let (data, response) = try await session.data(for: request)
        
        if let http = response as? HTTPURLResponse,
              !(200...299).contains(http.statusCode) {
            throw APIError.statusCode(http.statusCode)
        }
        
        // Cache the response manually (since Authorization headers prevent auto-caching)
        if let response = response as? HTTPURLResponse {
            #if DEBUG
            print("Caching response for bar hours with status code: \(response.statusCode)")
            #endif
            let cachedResponse = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedResponse, for: request)
            
            // Store timestamp
            UserDefaults.standard.set(Date(), forKey: "barHours_cache_timestamp")
        }
        
        return try self.decoder.decode([BarHours].self, from: data)
    }
    
    func barHoursBulkUpdate(hour: BarHours) async throws {
        let endpoint = baseURL + "bar-hours/bulk_update/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await session.data(for: request)
        
        if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) {
            throw APIError.statusCode(response.statusCode)
        }
    }
    
    func patchBarHours(id: Int, hour: BarHours) async throws {
        let endpoint = baseURL + "bar-hours/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw BarHoursError.doesNotExist("Could not find bar hours with id: \(id)")
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try encoder.encode(hour)
        
        let (_, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
    }
    
    func deleteBarHours(id: Int) async throws {
        let endpoint = baseURL + "bar-hours/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue( "application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await session.data(for: request)
        
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
            throw APIError.statusCode(response.statusCode)
        }
    }
    
    // MARK: Bar Status
    
    func fetchStatuses() async throws -> [BarStatus] {
        let endpoint = baseURL + "bar-status/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.cachePolicy = .returnCacheDataElseLoad
        
        // Check if we have a cached response first and if it's still valid
        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let cacheDate = UserDefaults.standard.object(forKey: "barStatuses_cache_timestamp") as? Date {
            
            let isExpired = Date().timeIntervalSince(cacheDate) > barStatusCache
            if !isExpired {
                #if DEBUG
                print("Using cached bar statuses data (valid)")
                #endif
                return try timeStampDecoder.decode([BarStatus].self, from: cachedResponse.data)
            } else {
                #if DEBUG
                print("Cache expired. Fetching new bar statuses data.")
                #endif
                URLCache.shared.removeCachedResponse(for: request)
                UserDefaults.standard.removeObject(forKey: "barStatuses_cache_timestamp")
            }
        }
        
        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw APIError.statusCode(httpResponse.statusCode)
        }
        
        // Cache the response manually (since Authorization headers prevent auto-caching)
        #if DEBUG
        print("Caching bar statuses data.")
        #endif
        let cachedResponse = CachedURLResponse(response: response, data: data)
        URLCache.shared.storeCachedResponse(cachedResponse, for: request)
        
        // Store timestamp for cache expiration
        UserDefaults.standard.set(Date(), forKey: "barStatuses_cache_timestamp")
        
        return try timeStampDecoder.decode([BarStatus].self, from: data)
    }
    
    func fetchBarStatus(statusId: Int) async throws -> BarStatus {
        let endpoint = baseURL + "bar-status/\(statusId)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
            throw APIError.statusCode(response.statusCode)
        }
        
        return try decoder.decode(BarStatus.self, from: data)
    }
    
    func postBarStatus(barStatus: BarStatus) async throws -> BarStatus {
        let endpoint = baseURL + "bar-status/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try encoder.encode(barStatus)
        
        let (data, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
        return try decoder.decode(BarStatus.self, from: data)
    }
    
    func putBarStatus(_ status: BarStatus) async throws {
        let endpoint = baseURL + "bar-status/\(status.id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try encoder.encode(status)
        
        let (_, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
    }
    
    // MARK: Bars
    
    func fetchBar(id: Int) async throws -> Bar {
        let endpoint = baseURL + "bars/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
        return try decoder.decode(Bar.self, from: data)
    }
    
    func putBar(id: Int) async throws {
        let endpoint = baseURL + "bars/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
    }
    
    func patchBar(id: Int) async throws {
        let endpoint = baseURL + "bars/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
    }
    
    func deleteBar(id: Int) async throws {
        let endpoint = baseURL + "bars/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
            throw APIError.statusCode(response.statusCode)
        }
    }
    
    func fetchAllBars() async throws -> [Bar] {
        let endpoint = baseURL + "bars/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.cachePolicy = .returnCacheDataElseLoad
        
        // Check if we have a cached response first
        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            #if DEBUG
            print("Using cached bars data (valid)")
            #endif
            return try timeStampDecoder.decode([Bar].self, from: cachedResponse.data)
        }
        
        let (data, response) = try await session.data(for: request)
        
        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            throw APIError.statusCode(response.statusCode)
        }
        
        // Cache the response manually (since Authorization headers prevent auto-caching)
        if let response = response as? HTTPURLResponse {
            #if DEBUG
            print("Caching response for bars with status code: \(response.statusCode)")
            #endif
            let cachedResponse = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedResponse, for: request)
        }
        
        return try timeStampDecoder.decode([Bar].self, from: data)
    }
    
    func fetchMostActiveBars() async throws -> [Bar] {
        let endpoint = baseURL + "bars/most-active/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
        
        return try decoder.decode([Bar].self, from: data)
    }
    
    // MARK: Bar Images
    
    func fetchImages(for barID: Int) async throws -> [BarImage] {
        let endpoint = baseURL + "bars/\(barID)/images/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue( "application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
        
        return try decoder.decode([BarImage].self, from: data)
    }
    
    func postImage(for barID: Int) async throws -> BarImage {
        let endpoint = baseURL + "bars/\(barID)/images/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue( "application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
        
        // Leaving this here for now since way may need to return
        return try decoder.decode(BarImage.self, from: data)
    }
    
    func fetchBarImage(bar: Int, imageID: Int) async throws -> BarImage {
        let endpoint = baseURL + "bars/\(bar)/images/\(imageID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue( "application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
        
        return try decoder.decode(BarImage.self, from: data)
    }
    
    func updateBarImage(bar: Int, imageID: Int) async throws {
        let endpoint = baseURL + "bars/\(bar)/images/\(imageID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue( "application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
    }
    
    func patchBarImage(bar: Int, imageID: Int) async throws {
        let endpoint = baseURL + "bars/\(bar)/images/\(imageID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue( "application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
    }
    
    func deleteBarImage(barId: Int, imageId: Int) async throws {
        let endpoint = baseURL + "bars/\(barId)/images/\(imageId)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue( "application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
    }
    
    // MARK: Events
    
    func fetchEvents() async throws -> [Event] {
        let endpoint = baseURL + "events/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
        
        return try decoder.decode([Event].self, from: data)
    }
    
    func fetchEvent(id: Int) async throws -> Event {
        let endpoint = baseURL + "events/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
        
        return try decoder.decode(Event.self, from: data)
    }
    
    func postEvent(event: Event) async throws -> Event {
        let endpoint = baseURL + "events/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try encoder.encode(event)
        
        let (data, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
        
        return try decoder.decode(Event.self, from: data)
    }
    
    func putEvent(id: Int) async throws {
        let endpoint = baseURL + "events/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
    }
    
    func patchEvent(id: Int) async throws {
        let endpoint = baseURL + "events/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
    }
    
    func deleteEvent(id: Int) async throws {
        let endpoint = baseURL + "events/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL(url: endpoint)
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.statusCode(response.statusCode)
        }
    }
}
