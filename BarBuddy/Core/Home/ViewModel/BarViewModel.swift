//
//  BarViewModel.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/1/25.
//

import Foundation
import SwiftUI

@Observable
final class BarViewModel: Mockable {
    var bars: [Bar]
    var statuses: [BarStatus]
    var hours: [BarHours]
    @ObservationIgnored var networkManager: NetworkTestable
    @ObservationIgnored private var hasFetchedBars = false
    
    // Background refresh timers
    @ObservationIgnored private var statusRefreshTimer: Timer?
    @ObservationIgnored private let statusRefreshInterval: TimeInterval = 300 // 5 minutes
    
    // Track last refresh time
    @ObservationIgnored private var lastRefreshTime: Date = Date()
    
    init(networkManager: NetworkTestable = BarNetworkManager.shared) {
        self.networkManager = networkManager
        self.bars = []
        self.statuses = []
        self.hours = []
        
        startStatusRefreshTimer()
    }
    
    func handleScenePhaseChange(_ scenePhase: ScenePhase) async {
        switch scenePhase {
        case .active:
            let timeSinceLastRefresh = Date().timeIntervalSince(lastRefreshTime)
            
            // If more than 5 minutes have passed, refresh immediately
            if timeSinceLastRefresh >= statusRefreshInterval {
                print("App became active, refreshing data immediately...")
                await refreshBarStatuses()
            }
            
            // Restart timer if it's not running
            if statusRefreshTimer == nil {
                startStatusRefreshTimer()
            }
            
        case .background:
            // Stop timer to save battery when in background
            stopStatusRefreshTimer()
            
        case .inactive:
            // Do nothing for inactive state
            break
            
        @unknown default:
            break
        }
    }
    
    // Background refresh methods
    private func startStatusRefreshTimer() {
        statusRefreshTimer?.invalidate()
        statusRefreshTimer = Timer.scheduledTimer(withTimeInterval: statusRefreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshBarStatuses()
            }
        }
    }
    
    private func refreshBarStatuses() async {
        do {
            print("Background refresh: Fetching bar statuses...")
            let fetchedStatuses = try await networkManager.fetchStatuses()
            self.statuses = fetchedStatuses
            self.lastRefreshTime = Date()
            
        } catch {
            print("Background refresh error: \(error.localizedDescription)")
        }
    }
    
    func stopStatusRefreshTimer() {
        statusRefreshTimer?.invalidate()
        statusRefreshTimer = nil
    }
    
    // MARK: - Load Data
    
    func loadBarData() async throws {
        var retries = 0
        let maxRetries = 3
        let retryDelay: UInt64 = 2_000_000_000 // 2 seconds in nanoseconds

        while retries < maxRetries {
            do {
                // Attempt to fetch bar data
                async let fetchedStatuses = networkManager.fetchStatuses()
                async let fetchedBars = networkManager.fetchAllBars()
                async let fetchedHours = networkManager.fetchAllBarHours()
                
                do {
                    let (statuses, bars, hours) = try await (fetchedStatuses, fetchedBars, fetchedHours)
                    self.statuses = statuses
                    self.bars = bars
                    self.hours = hours
                    retries = maxRetries // Exit loop on success
                } catch let error as NSError where error.domain == NSURLErrorDomain {
                    handleNetworkError(error, context: "Load Bar Data")
                    retries += 1
                    try await Task.sleep(nanoseconds: retryDelay)
                } catch let apiError as APIError {
                    handleAPIError(apiError, context: "Load Bar Data")
                    retries += 1
                    try await Task.sleep(nanoseconds: retryDelay)
                } catch {
                    print("Load Bar Data ERROR - \(error)")
                    retries += 1
                    try await Task.sleep(nanoseconds: retryDelay)
                }
            } catch {
                throw BarViewModelError.maxRetriesExceeded
            }
        }
    }
    
    func formatBarHours(hours: inout BarHours) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        guard
            let open = hours.openTime,
            let close = hours.closeTime
        else {
            print("One of the opening/closing times is nil for bar \(hours.bar).")
            return nil
        }
        let closed = isClosed(open, close)
        hours.isClosed = closed
        return "\(closed ? "Closed" : "Open"): \(formatter.string(from: open)) - \(formatter.string(from: close))"
    }
    
//    func getMostVotedWaitTime(barId: Int) async throws {
//        // Check if barId is valid
//        guard let index = statuses.firstIndex(where: { $0.bar == barId }) else {
//            print("No status found for bar \(barId)")
//            throw BarViewModelError.statusNotFound
//        }
//        print("Fetching new wait time from server...")
//
//        let votes = try await networkManager.fetchAllVotes().filter { $0.bar == barId }
//
//        // If no votes found, set default to "N/A"
//        var countMap: [String: Int] = [:]
//        votes.forEach { countMap[$0.waitTime, default: 0] += 1 }
//        let mostVotedTime = countMap.max { $0.value < $1.value }?.key ?? "N/A"
//
//        statuses[index].waitTime = mostVotedTime
//        cacheWaitTime(mostVotedTime, for: barId)
//
//        // Update the server with the most voted time if it differs
//        let previousServerStatus = try? await networkManager.fetchBarStatus(statusId: statuses[index].id)
//        if previousServerStatus?.waitTime != mostVotedTime {
//            try await networkManager.putBarStatus(statuses[index])
//            print("\nUpdated server with new most voted wait time: \(mostVotedTime)")
//        } else {
//            print("Server already has most voted time, skipping update.")
//        }
//    }
    
    private func cacheWaitTime(_ time: String, for barId: Int) {
        var waitTimeCache = UserDefaults.standard.dictionary(forKey: "barVotes_wait_time_cache") as? [String: String] ?? [:]
        waitTimeCache["\(barId)"] = time
        UserDefaults.standard.set(waitTimeCache, forKey: "barVotes_wait_time_cache")
    }

    
    func hasCachedWaitTime(for barId: Int) -> Bool {
        statuses.contains(where: { $0.bar == barId })
    }
    
    internal func isClosed(_ openTime: Date, _ closeTime: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        let openComponents = calendar.dateComponents([.hour, .minute], from: openTime)
        let closeComponents = calendar.dateComponents([.hour, .minute], from: closeTime)
        
        var todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        
        todayComponents.hour = openComponents.hour
        todayComponents.minute = openComponents.minute
        guard let openDate = calendar.date(from: todayComponents) else {
            return true
        }
        
        todayComponents.hour = closeComponents.hour
        todayComponents.minute = closeComponents.minute
        guard var closeDate = calendar.date(from: todayComponents) else {
            return true
        }
        
        if closeDate <= openDate {
            closeDate = calendar.date(byAdding: .day, value: 1, to: closeDate)!
        }
        
        if now < openDate {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
            var yesterdayComponents = calendar.dateComponents([.year, .month, .day], from: yesterday)
            
            yesterdayComponents.hour = openComponents.hour
            yesterdayComponents.minute = openComponents.minute
            guard let previousOpenDate = calendar.date(from: yesterdayComponents) else {
                return true
            }
            
            yesterdayComponents.hour = closeComponents.hour
            yesterdayComponents.minute = closeComponents.minute
            guard var previousCloseDate = calendar.date(from: yesterdayComponents) else {
                return true
            }
            
            if previousCloseDate <= previousOpenDate {
                previousCloseDate = calendar.date(byAdding: .day, value: 1, to: previousCloseDate)!
            }
            
            return now < previousOpenDate || now >= previousCloseDate
        }
        
        return now < openDate || now >= closeDate
    }
    
    private func handleStatusCodeError(_ statusCode: Int) {
        print("Encountered an error with status code \(statusCode): ", terminator: "")
        switch statusCode {
        case 403:
            print("Forbidden. You do not have permission to perform this action.")
        case 404:
            print("Bar hours not found.")
        case 400:
            print("Bad request. Please check the data.")
        case 500:
            print("Server error. Please try again later.")
        default:
            print("Unexpected status code \(statusCode).")
        }
    }
    
    private func handleAPIError(_ error: APIError, context: String) {
        print("\(context) ERROR -", terminator: " ")
        switch error {
        case .noToken:
            print("No token available. Please log in.")
        case .statusCode(let statusCode):
            handleStatusCodeError(statusCode)
        case .invalidURL:
            print("The URL is not valid.")
        case .encoding(let encodingError):
            print("Encoding error: \(encodingError.localizedDescription)")
        case .decoding(let decodingError):
            print("Decoding error: \(decodingError.localizedDescription)")
        }
    }
    
    private func handleNetworkError(_ error: NSError, context: String) {
        print("\(context) ERROR:", terminator: " ")
        switch error.code {
        case NSURLErrorCannotParseResponse:
            print("Failed to parse response from the server.")
        case NSURLErrorNotConnectedToInternet:
            print("No internet connection. Please check your network settings.")
        case NSURLErrorTimedOut:
            print("The request timed out. Please try again later.")
        case NSURLErrorNetworkConnectionLost:
            print("Network connection was lost. Please check your internet connection.")
        default:
            print("An unexpected error occurred: \(error.localizedDescription)")
        }
    }
}

// MARK: - BarViewModel Preview
// Indtended only for Xcode previews and testing
#if DEBUG
extension BarViewModel {
    static let preview: BarViewModel = {
        let viewModel = BarViewModel()
        viewModel.bars = Bar.sampleBars
        viewModel.statuses = BarStatus.sampleStatuses
        viewModel.hours = BarHours.sampleHours
        viewModel.networkManager = MockBarNetworkManager()
        
        return viewModel
    }()
}
#endif

// MARK: - Protocol Conformance
extension BarViewModel: BarViewModelProtocol {}
