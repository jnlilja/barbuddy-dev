//
//  Mockable.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/4/25.
//

import Foundation

@MainActor
protocol Mockable {
    func getHours(for bar: Bar) async throws -> String?
    func isClosed(_ openTime: Date, _ closeTime: Date) -> Bool
}
