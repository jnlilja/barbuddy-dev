//
//  BarNetworkManager.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/18/25.
//  Updated — make models Sendable
//

import Foundation
@preconcurrency import FirebaseAuth

actor BarNetworkManager: NetworkMockable {
    static let shared = BarNetworkManager()
    private let session: URLSession
    private let baseURL = ProcessInfo.processInfo.environment["BASE_URL"] ?? ""
    private let (encoder, decoder) = (JSONEncoder(), JSONDecoder())
    
    internal init(session: URLSession = .shared) {
        self.session = session
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        encoder.keyEncodingStrategy = .convertToSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: Bar Vote
    
    // GET /bar-votes/summary/
    func fetchVoteSummaries() async throws -> [BarVote] {
        let endpoint = baseURL + "bar-votes/summary/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.badResponse(response.statusCode)
        }
        return try decoder.decode([BarVote].self, from: data)
    }
    
    // POST /bar-votes/
    func submitVote(vote: BarVote) async throws {
        let endpoint = baseURL + "bar-votes/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    func fetchBarVote(for voteID: Int) async throws -> BarVote {
        let endpoint = baseURL + "bar-votes/\(voteID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(httpResponse.statusCode)
        }
        
        return try decoder.decode(BarVote.self, from: data)
    }
    
    func putBarVote(voteID: Int) async throws {
        let endpoint = baseURL + "bar-votes/\(voteID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    func patchBarVote(voteID: Int) async throws {
        let endpoint = baseURL + "bar-votes/\(voteID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    func deleteBarVote(voteID: Int) async throws {
        let endpoint = baseURL + "bar-votes/\(voteID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    // MARK: Bar Hours
    
    func postBarHours(hours: BarHours) async throws -> BarHours {
        let endpoint = baseURL + "bar-hours/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
        
        return try decoder.decode(BarHours.self, from: data)
    }
    
    func fetchBarHours(for barHoursId: Int) async throws -> BarHours {
        let endpoint = baseURL + "bar-hours/\(barHoursId)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
                throw APIError.badResponse(http.statusCode)
            }
        
        return try decoder.decode(BarHours.self, from: data)
    }
    
    func fetchAllBarHours() async throws -> [BarHours] {
        let endpoint = baseURL + "bar-hours/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        if let http = response as? HTTPURLResponse,
              !(200...299).contains(http.statusCode) {
            throw APIError.badResponse(http.statusCode)
        }
        
        // The API returns time as HH:mm:ss, so we need to decode it accordingly
        let hoursDecoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        hoursDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return try hoursDecoder.decode([BarHours].self, from: data)
    }
    
    func barHoursBulkUpdate(hour: BarHours) async throws {
        let endpoint = baseURL + "bar-hours/bulk_update/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    func patchBarHours(id: Int) async throws {
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
        
        let (_, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    func deleteBarHours(id: Int) async throws {
        let endpoint = baseURL + "bar-hours/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    // MARK: Bar Status
    
    func fetchStatuses() async throws -> [BarStatus] {
        let endpoint = baseURL + "bar-status/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw APIError.badResponse(httpResponse.statusCode)
        }
        
        // Since this data contains microseconds in the date, we need a custom decoder
        let customDecoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        customDecoder.dateDecodingStrategy = .formatted(formatter)
        return try decoder.decode([BarStatus].self, from: data)
    }
    
    func fetchBarStatus(statusID: Int) async throws -> BarStatus {
        let endpoint = baseURL + "bar-status/\(statusID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) {
            throw APIError.badResponse(response.statusCode)
        }
        
        return try decoder.decode(BarStatus.self, from: data)
    }
    
    func postBarStatus(barStatus: BarStatus) async throws -> BarStatus {
        let endpoint = baseURL + "bar-status/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
        return try decoder.decode(BarStatus.self, from: data)
    }
    
    func putBarStatus(_ status: BarStatus) async throws {
        let endpoint = baseURL + "bar-status/\(status.id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    func patchBarStatus(statusID: Int, status: BarStatus) async throws {
        struct patchStruct: Encodable {
            //let crowdSize: String?
            let waitTime: String?
        }

        let endpoint = baseURL + "bar-status/\(statusID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
        }
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            throw APIError.noToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let patch = patchStruct(waitTime: status.waitTime)
        request.httpBody = try encoder.encode(patch)
        
        let (_, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode)  {
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    func deleteBarStatus(statusID: Int) async throws {
        let endpoint = baseURL + "bar-status/\(statusID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    // MARK: Bars
    
    func fetchBar(id: Int) async throws -> Bar {
        let endpoint = baseURL + "bars/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
        return try decoder.decode(Bar.self, from: data)
    }
    
    func putBar(id: Int) async throws {
        let endpoint = baseURL + "bars/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    func patchBar(id: Int) async throws {
        let endpoint = baseURL + "bars/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    func deleteBar(id: Int) async throws {
        let endpoint = baseURL + "bars/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    func getBarAggretedVote(id: Int) async throws -> Bar {
        let endpoint = baseURL + "bars/\(id)/aggregated-vote/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
        return try decoder.decode(Bar.self, from: data)
    }
    
    func fetchAllBars() async throws -> [Bar] {
        let endpoint = baseURL + "bars/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
            throw APIError.badResponse(response.statusCode)
        }
        return try decoder.decode([Bar].self, from: data)
    }
    
    func fetchMostActiveBars() async throws -> [Bar] {
        let endpoint = baseURL + "bars/most-active/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
        
        return try decoder.decode([Bar].self, from: data)
    }
    
    // MARK: Bar Images
    
    func fetchImages(for barID: Int) async throws -> [BarImage] {
        let endpoint = baseURL + "bars/\(barID)/images/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
        
        return try decoder.decode([BarImage].self, from: data)
    }
    
    func postImage(for barID: Int) async throws -> BarImage {
        let endpoint = baseURL + "bars/\(barID)/images/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
        
        // Leaving this here for now since way may need to return
        return try decoder.decode(BarImage.self, from: data)
    }
    
    func fetchBarImage(bar: Int, imageID: Int) async throws -> BarImage {
        let endpoint = baseURL + "bars/\(bar)/images/\(imageID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
        
        return try decoder.decode(BarImage.self, from: data)
    }
    
    func updateBarImage(bar: Int, imageID: Int) async throws {
        let endpoint = baseURL + "bars/\(bar)/images/\(imageID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    func patchBarImage(bar: Int, imageID: Int) async throws {
        let endpoint = baseURL + "bars/\(bar)/images/\(imageID)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    func deleteBarImage(barId: Int, imageId: Int) async throws {
        let endpoint = baseURL + "bars/\(barId)/images/\(imageId)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    // MARK: Events
    
    func fetchEvents() async throws -> [Event] {
        let endpoint = baseURL + "events/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
        
        return try decoder.decode([Event].self, from: data)
    }
    
    func fetchEvent(id: Int) async throws -> Event {
        let endpoint = baseURL + "events/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
        
        return try decoder.decode(Event.self, from: data)
    }
    
    func postEvent(event: Event) async throws -> Event {
        let endpoint = baseURL + "events/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
        
        return try decoder.decode(Event.self, from: data)
    }
    
    func putEvent(id: Int) async throws {
        let endpoint = baseURL + "events/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    func patchEvent(id: Int) async throws {
        let endpoint = baseURL + "events/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
    }
    
    func deleteEvent(id: Int) async throws {
        let endpoint = baseURL + "events/\(id)/"
        guard let url = URL(string: endpoint) else {
            throw APIError.badURL
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
            throw APIError.badResponse(response.statusCode)
        }
    }
}
