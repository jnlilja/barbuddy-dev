//
//  APIError.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/16/25.
//

import Foundation   // ← gives access to LocalizedError

/// All networking / auth‑related failures in one place.
enum APIError: Error {
    case badURL
    case noToken
    case transport(Error)    // URLSession / Auth failures
    case encoding(Error)     // JSONEncoder / JSONSerialization failed
    case decoding(Error)     // JSONDecoder failed
}

/// Human‑readable error strings (optional but nice for alerts).
extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badURL:            return "Bad URL."
        case .noToken:           return "No Firebase idToken."
        case .transport(let e):  return e.localizedDescription
        case .encoding(let e):   return "Encoding failed: \(e.localizedDescription)"
        case .decoding(let e):   return "Decoding failed: \(e.localizedDescription)"
        }
    }
}
