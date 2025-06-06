//
//  JSONDecoder.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/5/25.
//

import Foundation

// MARK: - JSONDecoder Extensions
// Configured JSONDecoders for common use cases in BarBuddy.

extension JSONDecoder {
    /// Builds a fresh, default decoder.
    static var `default`: JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return d
    }

    /// Builds a fresh decoder configured for “HH:mm:ss” times.
    static var timeOnly: JSONDecoder {
        let d = JSONDecoder.default
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.dateFormat = "HH:mm:ss"
        d.dateDecodingStrategy = .formatted(fmt)
        return d
    }

    /// Builds a fresh decoder for microsecond timestamps.
    static var microseconds: JSONDecoder {
        let d = JSONDecoder.default
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        d.dateDecodingStrategy = .formatted(fmt)
        return d
    }

    /// Clones this decoder’s configuration to a new instance.
    func copy() -> JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = keyDecodingStrategy
        d.dateDecodingStrategy = dateDecodingStrategy
        d.dataDecodingStrategy = dataDecodingStrategy
        d.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
        return d
    }
}
