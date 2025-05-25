//
//  VoteViewModel.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/19/25.
//

import Foundation

// Handles vote counting
@MainActor
@Observable
final class VoteViewModel {
    // Holds the occurence count of each wait time vote
    private var waitTimeVotes: [String : Int] = [:]
    
    // After vote has been submitted, this function will be called to calculate the votes
    func calculateVotes(for barId: Int) async throws {
        let barVotes = try await BarNetworkManager.shared.fetchVoteSummaries()
            .filter { $0.bar == barId }
            
        // Reset wait time votes
        waitTimeVotes.removeAll()

        // Count votes for wait time
        barVotes.forEach {
            waitTimeVotes[$0.waitTime, default: 0] += 1
        }
        
        // Ensure there are votes to process
        guard var status = try await BarNetworkManager.shared.fetchStatuses().first(where: { $0.bar == barId }) else {
            throw VoteError.noStatus
        }
        status.waitTime = getMostVotedWaitTime()
        
        guard let statusId = status.id else {
            throw VoteError.missingId
        }
        
        status.lastUpdated = DateFormatter.formatTimeStamp(Date())
        
        try await BarNetworkManager.shared.patchBarStatus(statusID: statusId)
    }
    
    private func getMostVotedWaitTime() -> String? {
        return waitTimeVotes.max(by: { $0.value < $1.value })?.key
    }
}

enum VoteError: Error {
    case noVotes
    case missingId
    case noStatus
}
