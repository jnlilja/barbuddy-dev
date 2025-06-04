//
//  APIError.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/16/25.
//

import Foundation

/// All networking / auth‑related failures in one place.
enum APIError: Error {
    case badURL
    case noToken
    case noUser
    case badResponse(Int) // HTTP status code, e.g. 404, 500
    case serverError
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
        case .noUser:
            return "No User"
        case .badResponse:
            return "Bad Request"
        case .serverError:
            return "Server Error"
        }
    }
}
