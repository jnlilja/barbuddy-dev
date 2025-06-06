//
//  BarBuddyTests.swift
//  BarBuddyTests
//
//  Created by Jessica Lilja on 2/5/25.
//  Commit and push test

import Foundation
import Testing

@testable import BarBuddy

@MainActor
@Suite("BarViewModel Vote Tests")
struct VoteTests {

    // MARK: - Test Cases
    @Test("Most voted wait time is calculated correctly")
    func testGetMostVotedWaitTime_CalculatesCorrectly() async throws {
        // Given
        let mockNetworkManager = MockBarNetworkManager()
        let viewModel = BarViewModel(networkManager: mockNetworkManager)

        // Setup test data
        mockNetworkManager.mockVotes = [
            BarVote(bar: 1, waitTime: "<5 min"),
            BarVote(bar: 1, waitTime: "<5 min"),
            BarVote(bar: 1, waitTime: "10-15 min"),
            BarVote(bar: 2, waitTime: "15-20 min"),  // Different bar, should be filtered out
        ]

        viewModel.statuses = [
            BarStatus(id: 1, bar: 1, waitTime: "10-15 min", lastUpdated: Date())
        ]

        // When
        try await viewModel.getMostVotedWaitTime(barId: 1)

        // Then
        let updatedStatus = viewModel.statuses.first(where: { $0.bar == 1 })
        #expect(
            updatedStatus?.waitTime == "<5 min",
            "Should update to most voted wait time"
        )
        #expect(
            mockNetworkManager.didCallFetchVoteSummaries,
            "Should fetch vote summaries"
        )
        #expect(
            mockNetworkManager.didCallPutBarStatus,
            "Should update bar status"
        )
        #expect(
            mockNetworkManager.capturedBarStatus?.waitTime == "<5 min",
            "Should pass correct status to API"
        )
    }

    @Test("Uses default wait time when no votes exist")
    func testGetMostVotedWaitTime_UsesDefaultWhenNoVotes() async throws {
        // Given
        let mockNetworkManager = MockBarNetworkManager()
        let viewModel = BarViewModel(networkManager: mockNetworkManager)

        mockNetworkManager.mockVotes = []  // No votes
        viewModel.statuses = [
            BarStatus(id: 1, bar: 1, waitTime: "10-15 min", lastUpdated: Date())
        ]

        // When
        try await viewModel.getMostVotedWaitTime(barId: 1)

        // Then
        let updatedStatus = viewModel.statuses.first(where: { $0.bar == 1 })
        #expect(
            updatedStatus?.waitTime == "<5 min",
            "Should use default wait time when no votes"
        )
    }

    @Test("Handles tie in votes correctly")
    func testGetMostVotedWaitTime_HandlesTie() async throws {
        // Given
        let mockNetworkManager = MockBarNetworkManager()
        let viewModel = BarViewModel(networkManager: mockNetworkManager)

        mockNetworkManager.mockVotes = [
            BarVote(bar: 1, waitTime: "<5 min"),
            BarVote(bar: 1, waitTime: "10-15 min"),
        ]

        viewModel.statuses = [
            BarStatus(id: 1, bar: 1, waitTime: "30> min", lastUpdated: Date())
        ]

        // When
        try await viewModel.getMostVotedWaitTime(barId: 1)

        // Then
        let updatedStatus = viewModel.statuses.first(where: { $0.bar == 1 })
        // In case of tie, max(by:) returns the first maximum element found
        #expect(updatedStatus?.waitTime != nil, "Should handle tie gracefully")
    }

    @Test("Throws error when bar status not found")
    func testGetMostVotedWaitTime_ThrowsWhenBarNotFound() async {
        // Given
        let mockNetworkManager = MockBarNetworkManager()
        let viewModel = BarViewModel(networkManager: mockNetworkManager)

        mockNetworkManager.mockVotes = [
            BarVote(bar: 1, waitTime: "<5 min")
        ]

        viewModel.statuses = []  // No matching bar status

        // When/Then
        do {
            try await viewModel.getMostVotedWaitTime(barId: 1)
            #expect(Bool(false), "Should have thrown an error")
        } catch {
            #expect(
                throws: BarViewModelError.statusNotFound,
                "Should throw no status found error"
            ) {
                throw error
            }
        }

        #expect(
            mockNetworkManager.didCallFetchVoteSummaries,
            "Should still fetch votes"
        )
        #expect(
            !mockNetworkManager.didCallPutBarStatus,
            "Should not call putBarStatus"
        )
    }

    @Test("Handles network error gracefully")
    func testGetMostVotedWaitTime_HandlesNetworkError() async {
        // Given
        let mockNetworkManager = MockBarNetworkManager()
        let viewModel = BarViewModel(networkManager: mockNetworkManager)

        mockNetworkManager.mockError = APIError.statusCode(500)
        viewModel.statuses = [
            BarStatus(id: 1, bar: 1, waitTime: "10-15 min", lastUpdated: Date())
        ]

        // When/Then
        await #expect(throws: APIError.self) {
            try await viewModel.getMostVotedWaitTime(barId: 1)
        }
    }

    @Test("Filters votes by correct bar ID")
    func testGetMostVotedWaitTime_FiltersVotesByBarId() async throws {
        // Given
        let mockNetworkManager = MockBarNetworkManager()
        let viewModel = BarViewModel(networkManager: mockNetworkManager)

        mockNetworkManager.mockVotes = [
            BarVote(bar: 1, waitTime: "<5 min"),
            BarVote(bar: 2, waitTime: "10-15 min"),
            BarVote(bar: 2, waitTime: "10-15 min"),
            BarVote(bar: 2, waitTime: "10-15 min"),
        ]

        viewModel.statuses = [
            BarStatus(id: 1, bar: 1, waitTime: "20+ min", lastUpdated: Date())
        ]

        // When
        try await viewModel.getMostVotedWaitTime(barId: 1)

        // Then
        let updatedStatus = viewModel.statuses.first(where: { $0.bar == 1 })
        #expect(
            updatedStatus?.waitTime == "<5 min",
            "Should only consider votes for the specified bar"
        )
    }
}

// MARK: - Test Data Factory
extension VoteTests {
    static func createBarVote(bar: Int = 1, waitTime: String = "<5 min")
        -> BarVote
    {
        BarVote(bar: bar, waitTime: waitTime)
    }

    static func createBarStatus(
        id: Int = 1,
        bar: Int = 1,
        waitTime: String = "10-15 min"
    ) -> BarStatus {
        BarStatus(id: id, bar: bar, waitTime: waitTime, lastUpdated: Date())
    }
}

@MainActor
@Suite("Test IsClosed Functionality")
struct TestIsBarClosed {
    @Test("Sucsessfully detects bar is closed")
    func testIsClosed_ClosedResponse() async throws {
        // Given
        let viewModel = MockBarViewModel()

        // When
        viewModel.currentTime = "1:00 AM"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"

        let openTime = dateFormatter.date(from: "10:00 AM")!
        let closeTime = dateFormatter.date(from: "2:00 AM")!

        // Then
        #expect(viewModel.isClosed(openTime, closeTime) == true)
    }

    @Test("Sucsessfully detects bar is open")
    func testIsClosed_OpenResponse() async throws {
        // Given
        let viewModel = MockBarViewModel()

        // When
        viewModel.currentTime = "1:00 PM"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"

        let openTime = dateFormatter.date(from: "10:00 AM")!
        let closeTime = dateFormatter.date(from: "2:00 AM")!

        // Then
        #expect(viewModel.isClosed(openTime, closeTime) == false)
    }
}

@MainActor
@Suite("Test BarViewModel getHours Functionality")
struct TestGetHours {
    @Test("Sucsessfully returns correct hours")
    func testGetHours_Success() async throws {
        // Given
        let viewModel = MockBarViewModel()

        let openTime = "10:00 AM"
        let closeTime = "2:00 AM"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let openTimeDate = dateFormatter.date(from: openTime)!
        let closeTimeDate = dateFormatter.date(from: closeTime)!

        // When
        let testBar = Bar(
            id: 1,
            name: "",
            address: "",
            averagePrice: "",
            location: Location(latitude: 1, longitude: 1),
            usersAtBar: [],
            currentStatus: CurrentStatus(crowdSize: 0, waitTime: 0, lastUpdated: Date()),
            averageRating: 0,
            images: [],
            currentUserCount: 0,
            activityLevel: ""
        )
        viewModel.mockHours.append(BarHours(id: 1, bar: 1, day: "Monday", openTime: openTimeDate, closeTime: closeTimeDate, isClosed: false))
        let hours = try await viewModel.getHours(for: testBar)
        viewModel.currentTime = "1:00 PM"
        
        // Then
        let expectedHours = "Open: \(openTime) - \(closeTime)"
        #expect(hours == expectedHours, "Should return correct hours")
    }
}
