//
//  BarBuddyError.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/25/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case decodingFailed
    case idTokenDecodingFailed
    case httpError
    case pictureDecodingFailed
    case primaryPictureEncodingFailed
}
