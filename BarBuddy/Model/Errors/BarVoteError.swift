//
//  BarVoteError.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/5/25.
//

import Foundation

enum BarVoteError: Error, LocalizedError {
    case alreadyVoted
    case voteNotFound
    case invalidVoteValue
    case coolDownPeriodNotMet
    
    var errorDescription: String? {
        switch self {
        case .alreadyVoted:
            return "You have already voted for this bar."
        case .voteNotFound:
            return "The vote could not be found."
        case .invalidVoteValue:
            return "The vote value is invalid."
        case .coolDownPeriodNotMet:
            return "You must wait 5 minutes before voting again for this bar."
        }
    }
}
