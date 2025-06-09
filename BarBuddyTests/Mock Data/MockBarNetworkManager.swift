//
//  File.swift
//  BarBuddyTests
//
//  Created by Andrew Betancourt on 6/4/25.
//

import Foundation

@MainActor
// MARK: - Mock Network Manager
final class MockBarNetworkManager: NetworkTestable {
    // MARK: - Test Data Storage
    var mockVotes: [BarVote] = []
    var mockBarStatus: BarStatus?
    var mockError: Error?
    
    // MARK: - Call Tracking
    var didCallFetchVoteSummaries = false
    var didCallPutBarStatus = false
    var capturedBarStatus: BarStatus?
    var fetchVoteSummariesCallCount = 0
    var putBarStatusCallCount = 0
    
    // MARK: - Protocol Implementation
    func fetchAllVotes() async throws -> [BarVote] {
        didCallFetchVoteSummaries = true
        fetchVoteSummariesCallCount += 1
        
        if let error = mockError {
            throw error
        }
        return mockVotes
    }
    
    func putBarStatus(_ status: BarStatus) async throws {
        didCallPutBarStatus = true
        putBarStatusCallCount += 1
        capturedBarStatus = status
        
        if let error = mockError {
            throw error
        }
    }
    
    func patchBarHours(id: Int) async throws {
        if let error = mockError {
            throw error
        }
    }
    
    // MARK: - Test Helpers
    func reset() {
        mockVotes = []
        mockBarStatus = nil
        mockError = nil
        didCallFetchVoteSummaries = false
        didCallPutBarStatus = false
        capturedBarStatus = nil
        fetchVoteSummariesCallCount = 0
        putBarStatusCallCount = 0
    }
    
    func fetchAllBarHours() async throws -> [BarHours] {
        // Setup mock data
        let time = DateFormatter()
        time.dateFormat = "h:mm a"
        time.locale = Locale(identifier: "en_US_POSIX")
        
        return [
            BarHours(
                id: 1,
                bar: 1,
                day: "Monday",
                openTime: time.date(from: "10:00 AM")!,
                closeTime: time.date(from: "2:00 AM")!,
                isClosed: false
            )
        ]
    }
    
    // MARK: - Unused Methods
    // These methods are required by the protocol but not used in the tests
    func fetchAllBars() async throws -> [BarHours] { return [] }
    func fetchStatuses() async throws -> [BarStatus] { return [] }
    func patchBarHours(id: Int, hour: BarBuddy.BarHours) async throws {}
    func fetchAllBars() async throws -> [Bar] { return [] }
    func fetchBarStatus(statusId: Int) async throws -> BarStatus {
        return BarStatus(id: 1, bar: 1, crowdSize: "", waitTime: "", lastUpdated: Date())
    }
}
