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

    @Test("Fetch Status by Bar ID")
    func testGetMostVotedWaitTime_FiltersVotesByBarId() async throws {
        // Given
        let mockNetworkManager = MockBarNetworkManager()
        let viewModel = MockBarViewModel()
        
        // When
        viewModel.mockStatuses = try await mockNetworkManager.fetchStatuses()

        // Then
        let updatedStatus = viewModel.mockStatuses.first(where: { $0.bar == 1 })
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
        BarStatus(id: id, bar: bar, crowdSize: "", waitTime: waitTime, lastUpdated: Date())
    }
}


@Suite("Test IsClosed Functionality")
struct TestIsBarClosed {
    @MainActor @Test("Sucsessfully detects bar is closed")
    func testIsClosed_ClosedResponse() throws {
        // Given
        let viewModel = MockBarViewModel()

        // When
        viewModel.currentTime = "3:00 AM"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"

        let openTime = dateFormatter.date(from: "10:00 AM")!
        let closeTime = dateFormatter.date(from: "2:00 AM")!

        // Then
        #expect(viewModel.isClosed(openTime, closeTime) == true)
    }

    @MainActor @Test("Sucsessfully detects bar is open")
    func testIsClosed_OpenResponse() throws {
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


@Suite("Test BarViewModel getHours Functionality")
struct TestGetHours {
    @MainActor @Test("Sucsessfully returns correct hours")
    func testGetHours_Success() throws {
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
            currentStatus: CurrentStatus(crowdSize: "", waitTime: "", lastUpdated: Date()),
            averageRating: 0,
            images: [],
            currentUserCount: 0,
            activityLevel: ""
        )
        viewModel.mockHours.append(BarHours(id: 1, bar: 1, day: "Monday", openTime: openTimeDate, closeTime: closeTimeDate, isClosed: false))
        let hours = try viewModel.getHours(for: testBar)
        viewModel.currentTime = "1:00 PM"
        
        // Then
        let expectedHours = "Open: \(openTime) - \(closeTime)"
        #expect(hours == expectedHours, "Should return correct hours")
    }
}
