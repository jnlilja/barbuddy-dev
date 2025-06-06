//
//  BarVoteError.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/5/25.
//

import Foundation

enum BarVoteError: Error {
    case alreadyVoted
    case voteNotFound
    case invalidVoteValue
}
