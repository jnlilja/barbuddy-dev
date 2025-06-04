//
//  BarViewModelError.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/3/25.
//

import Foundation

enum BarViewModelError: Error, LocalizedError, Equatable {
    case invalidBarID
    case barNotFound
    case networkError(String)
    case hoursAreNil
    case statusNotFound
}

// MARK: - LocalizedError Conformance
extension BarViewModelError {
    var errorDescription: String? {
        switch self {
        case .invalidBarID:
            return "The provided bar ID is invalid."
        case .barNotFound:
            return "No bar found with the given ID."
        case .networkError(let message):
            return "Network error occurred: \(message)"
        case .hoursAreNil:
            return "Bar hours data is unavailable."
        case .statusNotFound:
            return "Bar status could not be found."
        }
    }
}
