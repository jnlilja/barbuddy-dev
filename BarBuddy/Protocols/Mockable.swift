//
//  Mockable.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/4/25.
//

import Foundation

@MainActor
/// This protocol is used to determine if a viewModel can be mocked for testing purposes.
protocol Mockable {
    var networkManager: NetworkTestable { get }
    func isClosed(_ openTime: Date, _ closeTime: Date) -> Bool
}
