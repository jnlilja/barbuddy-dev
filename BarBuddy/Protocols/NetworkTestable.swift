//
//  BarNetworkManagerProtocal.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/4/25.
//

import Foundation

/* I mainly created this protocol to make it easier to mock the network manager in tests.
   This allows us to create a mock network manager that conforms to this protocol
   and return mock data for testing purposes.
*/
protocol NetworkTestable: Sendable {
    func fetchAllVotes() async throws -> [BarVote]
    func putBarStatus(_ status: BarStatus) async throws
    func patchBarHours(id: Int, hour: BarHours) async throws
    func fetchAllBarHours() async throws -> [BarHours]
    func fetchAllBars() async throws -> Bars
    func fetchStatuses() async throws -> [BarStatus]
    func fetchBarStatus(statusId: Int) async throws -> BarStatus
}
