//
//  BarViewModel.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/1/25.
//

import Foundation
import SwiftUI
import FirebaseAuth

@Observable
final class BarViewModel: Mockable {
    var bars: [Bar]
    var statuses: [BarStatus]
    var hours: [BarHours]
    @ObservationIgnored var networkManager: NetworkTestable
    
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
        
        if Auth.auth().currentUser != nil {
            startStatusRefreshTimer()
        }
    }
    
    func handleScenePhaseChange(_ scenePhase: ScenePhase) async {
        switch scenePhase {
        case .active:
            guard !isQuietHours(), Auth.auth().currentUser != nil else {
                return
            }
            let timeSinceLastRefresh = Date().timeIntervalSince(lastRefreshTime)
            let remaining = abs(timeSinceLastRefresh - statusRefreshInterval).truncatingRemainder(dividingBy: 300)
            
            // If more than 5 minutes have passed, refresh immediately
            if timeSinceLastRefresh >= statusRefreshInterval {
                await refreshBarStatuses()
                startStatusRefreshTimer(statusRefreshInterval - remaining)
            } else {
                startStatusRefreshTimer(remaining)
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
    
    private func isQuietHours() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        
        // Check if current hour is between 4 AM (inclusive) and 7 AM (exclusive)
        // This covers 4:00 AM - 6:59 AM
        return currentHour >= 4 && currentHour < 7
    }
    
    // Background refresh methods
    private func startStatusRefreshTimer(_ interval: TimeInterval = 300) {
        // Don't start timer if it's quiet hours (4 AM - 7 AM)
        guard !isQuietHours() else { return }

        statusRefreshTimer?.invalidate()
        statusRefreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshBarStatuses()
                
                if interval < self?.statusRefreshInterval ?? 300 {
                    self?.startStatusRefreshTimer()
                }
            }
        }
    }
    
    private func refreshBarStatuses() async {
        do {
            let fetchedStatuses = try await networkManager.fetchStatuses()
            self.statuses = fetchedStatuses
            self.lastRefreshTime = Date()
            
        } catch {
            
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
        let retryDelay: UInt64 = 2_000_000_000 // 2 seconds

        while retries < maxRetries {
            
            // Attempt to fetch bar data
            async let fetchedStatuses = networkManager.fetchStatuses()
            async let fetchedBars = networkManager.fetchAllBars()
            async let fetchedHours = networkManager.fetchAllBarHours()
            
            do {
                let (statuses, hours) = try await (fetchedStatuses, fetchedHours)
                var bars: [Bar] = try await fetchedBars
                reorderBars(&bars)
                
                self.statuses = statuses
                self.bars = bars
                self.hours = hours
                retries = maxRetries // Exit loop on success
                
            } catch let error as NSError where error.domain == NSURLErrorDomain {
                #if DEBUG
                handleNetworkError(error, context: "Load Bar Data")
                #endif
                
                retries += 1
                if retries == maxRetries {
                    throw error
                }
                try await Task.sleep(nanoseconds: retryDelay)
                
            } catch let apiError as APIError {
                #if DEBUG
                handleAPIError(apiError, context: "Load Bar Data")
                #endif
                
                retries += 1
                if retries == maxRetries {
                    throw apiError
                }
                try await Task.sleep(nanoseconds: retryDelay)
                
            } catch {
                #if DEBUG
                print("Load Bar Data ERROR - \(error)")
                #endif
                
                retries += 1
                if retries == maxRetries {
                    throw error
                }
                try await Task.sleep(nanoseconds: retryDelay)
            }
        }
    }
    // Reorder to have most popular bars at the top
    private func reorderBars(_ bars: inout [Bar]) {
        guard
            let hideaway = bars.first(where: { $0.name.localizedCaseInsensitiveContains("Hideaway") }),
            let openBar = bars.first(where: { $0.name.localizedCaseInsensitiveContains("Open") }),
            let local = bars.first(where: { $0.name.localizedCaseInsensitiveContains("Local") }),
            let shore = bars.first(where: { $0.name.localizedCaseInsensitiveContains("Shore Club") }),
            let fire = bars.first(where: { $0.name.localizedCaseInsensitiveContains("Firehouse")})
        else { return }
        
        bars.removeAll { $0.name.localizedCaseInsensitiveContains("Hideaway")}
        bars.removeAll { $0.name.localizedCaseInsensitiveContains("Open") }
        bars.removeAll { $0.name.localizedCaseInsensitiveContains("Local") }
        bars.removeAll { $0.name.localizedCaseInsensitiveContains("Shore Club") }
        bars.removeAll { $0.name.localizedCaseInsensitiveContains("Firehouse") }
        
        
        bars.insert(hideaway, at: 0)
        bars.insert(openBar, at: 1)
        bars.insert(local, at: 2)
        bars.insert(shore, at: 3)
        bars.insert(fire, at: 4)
    }
    
    func formatBarHours(hours: inout BarHours) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        guard
            let open = hours.openTime,
            let close = hours.closeTime
        else {
            return nil
        }
        let closed = isClosed(open, close)
        hours.isClosed = closed
        return "\(closed ? "Closed" : "Open"): \(formatter.string(from: open)) - \(formatter.string(from: close))"
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
    
    #if DEBUG
    private func handleStatusCodeError(_ statusCode: Int) {
        print("Encountered an error with status code \(statusCode):", terminator: " ")
        switch statusCode {
        case 403: print("Forbidden. You do not have permission to perform this action.")
        case 404: print("Bar hours not found.")
        case 400: print("Bad request. Please check the data.")
        case 500: print("Server error. Please try again later.")
        default: print("Unexpected status code \(statusCode).")
        }
    }
    
    private func handleAPIError(_ error: APIError, context: String) {
        print("\(context) ERROR -", terminator: " ")
        switch error {
        case .noToken: print("No token available. Please log in.")
        case .statusCode(let statusCode): handleStatusCodeError(statusCode)
        case .invalidURL: print("The URL is not valid.")
        case .encoding(let encodingError): print("Encoding error: \(encodingError.localizedDescription)")
        case .decoding(let decodingError): print("Decoding error: \(decodingError.localizedDescription)")
        }
    }
    
    private func handleNetworkError(_ error: NSError, context: String) {
        print("\(context) ERROR -", terminator: " ")
        switch error.code {
        case NSURLErrorCannotParseResponse: print("Failed to parse response from the server.")
        case NSURLErrorNotConnectedToInternet: print("No internet connection. Please check your network settings.")
        case NSURLErrorTimedOut: print("The request timed out.")
        case NSURLErrorNetworkConnectionLost: print("Network connection was lost. Please check your internet connection.")
        default: print("An unexpected error occurred: \(error.localizedDescription)")
        }
    }
    #endif
}
// MARK: - Protocol Conformance
extension BarViewModel: BarViewModelProtocol {}
