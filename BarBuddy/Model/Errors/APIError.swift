//
//  APIError.swift
//  BarBuddy
//
//  Created by Elliot Gambale on 4/16/25.
//

import Foundation

/// All networking / auth‑related failures in one place.
enum APIError: Error {
    case invalidURL(url: String)  // e.g. "https://api.example.com/resource"
    case noToken
    case statusCode(Int)  // HTTP status code, e.g. 404, 500
    case encoding(Error)  // JSONEncoder / JSONSerialization failed
    case decoding(Error)  // JSONDecoder failed

    /// Returns a user-friendly error description for the APIError.
    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "\(url) is not a valid URL."
        case .noToken:
            return "No Firebase idToken. Please sign in."
        case .encoding(let e):
            return "Encoding failed: \(e.localizedDescription)"
        case .decoding(let e):
            switch e {
            case DecodingError.dataCorrupted(let context):
                return "Decoding failed: \(context.debugDescription)"
            case DecodingError.typeMismatch(let type, let context):
                return "Decoding failed: Expected type \(type) but found \(context.debugDescription)."
            default:
                return "Decoding failed: \(e.localizedDescription)"
            }
        case .statusCode(let code):
            return "HTTP status code \(code) encountered."
        }
    }
}
