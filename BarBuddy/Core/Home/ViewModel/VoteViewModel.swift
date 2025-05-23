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
    private var crowdSizeVotes: [String : Int] = [:]
    private var waitTimeVotes: [String : Int] = [:]
    
    func calculateVotes(for barId: Int) async throws -> BarStatus {
        let barVotes = try await BarNetworkManager.shared.fetchVoteSummaries().filter { $0.bar == barId }
        
        for vote in barVotes {
            crowdSizeVotes[vote.crowdSize, default: 0] += 1
            waitTimeVotes[vote.waitTime, default: 0] += 1
        }
        
        var status = try await BarNetworkManager.shared.fetchBarStatus(statusID: barId)
        status.crowdSize = getMostVotedCrowdSize()
        status.waitTime = getMostVotedWaitTime()
        
        crowdSizeVotes.removeAll()
        waitTimeVotes.removeAll()
        
        guard let statusId = status.id else {
            throw VoteError.missingId
        }
        
        status.lastUpdated = Date().formatted(date: .numeric, time: .standard)
        return try await BarNetworkManager.shared.patchBarStatus(statusID: statusId)
    }
    
    func getMostVotedCrowdSize() -> String? {
        return crowdSizeVotes.max(by: { $0.value < $1.value })?.key
    }
    
    func getMostVotedWaitTime() -> String? {
        return waitTimeVotes.max(by: { $0.value < $1.value })?.key
    }
}

enum VoteError: Error {
    case noVotes
    case missingId
}
