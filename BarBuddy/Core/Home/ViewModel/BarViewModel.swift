//
//  BarViewModel.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/1/25.
//

import Foundation

@MainActor
@Observable
final class BarViewModel {
    var bars: Bars = []
    var statuses: [BarStatus] = []
    var hours: [BarHours] = []
    var events: [Event] = []
    
    func loadBarData() async {
        async let fetchedStatuses = BarNetworkManager.shared.fetchStatuses()
        async let fetchedBars = BarNetworkManager.shared.fetchAllBars()
        async let fetchedHours = BarNetworkManager.shared.fetchAllBarHours()
        async let fetchedEvents = BarNetworkManager.shared.fetchEvents()
        
        do {
            self.events = try await fetchedEvents
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            print("Bar Events fetch ERROR:", terminator: " ")
            switch error.code {
            case NSURLErrorCannotParseResponse:
                print("Failed to parse response from the server. Statuses may not be available.")
            case NSURLErrorNotConnectedToInternet:
                print("No internet connection. Please check your network settings.")
            case NSURLErrorTimedOut:
                print("The request timed out. Please try again later.")
            case NSURLErrorNetworkConnectionLost:
                print("Network connection was lost. Please check your internet connection.")
            default:
                print("An unexpected error occurred: \(error.localizedDescription)")
            }
        } catch let apiError as APIError {
            print("Bar Events fetch ERROR:", terminator: " ")
            switch apiError {
            case .noToken:
                print("No token available. Please log in.")
            case .badResponse(let statusCode):
                print("Bad response from the server. Status code: \(statusCode)")
            case .badURL:
                print("The URL is not valid.")
            case .serverError:
                print("Server error occurred. Please try again later.")
            case .transport(let transportError):
                print("Transport error: \(transportError.localizedDescription)")
            case .encoding(let encodingError):
                print("Encoding error: \(encodingError.localizedDescription)")
            case .decoding(let decodingError):
                print("Decoding error: \(decodingError.localizedDescription)")
            case .noUser:
                print("No user is currently logged in.")
            }
        } catch {
            print("lmao idk bruh you may be cooked 😭: \(error)")
        }

        do {
            self.statuses = try await fetchedStatuses
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            print("Bar Status fetch ERROR:", terminator: " ")
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
        } catch let apiError as APIError {
            print("Bar Status fetch ERROR:", terminator: " ")
            switch apiError {
            case .noToken:
                print("No token available. Please log in.")
            case .badResponse(let statusCode):
                print("Bad response from the server. Status code: \(statusCode)")
            case .badURL:
                print("The URL is not valid.")
            case .serverError:
                print("Server error occurred. Please try again later.")
            case .transport(let transportError):
                print("Transport error: \(transportError.localizedDescription)")
            case .encoding(let encodingError):
                print("Encoding error: \(encodingError.localizedDescription)")
            case .decoding(let decodingError):
                print("Decoding error: \(decodingError.localizedDescription)")
            case .noUser:
                print("No user is currently logged in.")
            }
        } catch {
            print("lmao idk bruh you may be cooked 😭: \(error)")
        }
        
        do {
            self.bars = try await fetchedBars
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            print("Bar fetch ERROR:", terminator: " ")
            switch error.code {
            case NSURLErrorCannotParseResponse:
                print("Failed to parse response from the server. Statuses may not be available.")
            case NSURLErrorNotConnectedToInternet:
                print("No internet connection. Please check your network settings.")
            case NSURLErrorTimedOut:
                print("The request timed out. Please try again later.")
            case NSURLErrorNetworkConnectionLost:
                print("Network connection was lost. Please check your internet connection.")
            default:
                print("An unexpected error occurred: \(error.localizedDescription)")
            }
        } catch let apiError as APIError {
            print("Bars fetch ERROR:", terminator: " ")
            switch apiError {
            case .noToken:
                print("No token available. Please log in.")
            case .badResponse(let statusCode):
                print("Bad response from the server. Status code: \(statusCode)")
            case .badURL:
                print("The URL is not valid.")
            case .serverError:
                print("Server error occurred. Please try again later.")
            case .transport(let transportError):
                print("Transport error: \(transportError.localizedDescription)")
            case .encoding(let encodingError):
                print("Encoding error: \(encodingError.localizedDescription)")
            case .decoding(let decodingError):
                print("Decoding error: \(decodingError.localizedDescription)")
            case .noUser:
                print("No user is currently logged in.")
            }
        } catch {
            print("lmao idk bruh you may be cooked 😭: \(error)")
        }
        
        do {
            self.hours = try await fetchedHours
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            print("Bar Hours fetch ERROR:", terminator: " ")
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
        } catch let apiError as APIError {
            print("Bar Hours fetch ERROR:", terminator: " ")
            switch apiError {
            case .noToken:
                print("No token available. Please log in.")
            case .badResponse(let statusCode):
                print("Bad response from the server. Status code: \(statusCode)")
            case .badURL:
                print("The URL is not valid.")
            case .serverError:
                print("Server error occurred. Please try again later.")
            case .transport(let transportError):
                print("Transport error: \(transportError.localizedDescription)")
            case .encoding(let encodingError):
                print("Encoding error: \(encodingError.localizedDescription)")
            case .decoding(let decodingError):
                print("Decoding error: \(decodingError.localizedDescription)")
            case .noUser:
                print("No user is currently logged in.")
            }
        } catch {
            print("lmao idk bruh you may be cooked 😭: \(error)")
        }
    }
    
    // Function to fetch the bar's hours
    func getHours(for bar: Bar) async -> String? {
        // Try to get from cache
        if var cached = await BarHoursCache.shared.get(for: bar.id) {
            
            // Get last cached status and check if it needs to be updated
            let previousClosedStatus = cached.isClosed
            let isCurrentlyClosed = isClosed(cached.openTime, cached.closeTime)
            
            // If the status has not changed, do not update
            guard previousClosedStatus != isCurrentlyClosed else {
                return "\(isCurrentlyClosed ? "Closed" : "Open"): \(cached.openTime) - \(cached.closeTime)"
            }
            cached.isClosed = isCurrentlyClosed
            
            // Patch hours and update cache
            do {
                try await BarNetworkManager.shared.patchBarHours(id: cached.id)
                await BarHoursCache.shared.set(value: cached, forKey: cached.id)
            } catch {
                switch error {
                case BarHoursError.doesNotExist(error: let error):
                    print("patchHours error: \(error)")
                case APIError.noToken:
                    print("patchHours error: No token. Please log in.")
                case APIError.badResponse:
                    print("patchHours error: Bad request")
                case APIError.badURL:
                    print("patchHours error: URL is not valid.")
                default:
                    print("Pathing hours failed with error - \(error.localizedDescription)")
                }
                return nil
            }
            return "\(isCurrentlyClosed ? "Closed" : "Open"): \(cached.openTime) - \(cached.closeTime)"
        }
        // Fetch all hours if not in cache
        do {
            let allHours = try await BarNetworkManager.shared.fetchAllBarHours()
            guard var hours = allHours.first(where: { $0.bar == bar.id }) else { return nil }
            
            // Cache all fetched hours
            for h in allHours {
                await BarHoursCache.shared.set(value: h, forKey: h.id)
            }
        
            let closed = isClosed(hours.openTime, hours.closeTime)
            hours.isClosed = closed
            
            // Patch hours and update cache
            do {
                try await BarNetworkManager.shared.patchBarHours(id: hours.id)
                await BarHoursCache.shared.set(value: hours, forKey: hours.id)
            } catch {
                switch error {
                case BarHoursError.doesNotExist(error: let error):
                    print("patchHours error: \(error)")
                case APIError.noToken:
                    print("patchHours error: No token. Please log in.")
                case APIError.badResponse:
                    print("patchHours error: Bad request")
                case APIError.badURL:
                    print("patchHours error: URL is not valid.")
                default:
                    print("Pathing hours failed with error - \(error.localizedDescription)")
                }
                return nil
            }
            return "\(closed ? "Closed" : "Open"): \(hours.openTime) - \(hours.closeTime)"
            
        } catch APIError.badResponse {
            print("Could not fetch hours")
        } catch APIError.noToken {
            print("Could not fetch hours. No token.")
        } catch APIError.badURL {
            print("Could not fetch hours. URL is not valid.")
        } catch {
            print("Could not fetch hours - \(error.localizedDescription)")
        }
        return nil
    }
    
    func formatBarHours(hours: inout BarHours) -> String? {
        let (open, close) = (hours.openTime, hours.closeTime)
        let closed = isClosed(open, close)
        hours.isClosed = closed
        return "\(closed ? "Closed" : "Open"): \(open) - \(close)"
    }
    
    // Check if the bar is closed based on the current time and the bar's hours
    private func isClosed(_ openTime: String, _ closeTime: String) -> Bool {
        // Only handle 12-hour format with AM/PM
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard
            let openDateRaw = formatter.date(from: openTime),
            let closeDateRaw = formatter.date(from: closeTime)
        else {
            return true
        }
        
        let calendar = Calendar.current
        
        // Get the current date and time
        let nowComponents = calendar.dateComponents(in: .current, from: Date())
        let now = calendar.date(from: nowComponents)!
        
        // Get today's open and close times
        var barHourComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        
        barHourComponents.hour = calendar.component(.hour, from: openDateRaw)
        barHourComponents.minute = calendar.component(.minute, from: openDateRaw)
        let openDate = calendar.date(from: barHourComponents)!
        
        barHourComponents.hour = calendar.component(.hour, from: closeDateRaw)
        barHourComponents.minute = calendar.component(.minute, from: closeDateRaw)
        var closeDate = calendar.date(from: barHourComponents)!
        
        // If close time is earlier than open, it means it goes into the next day
        if closeDate <= openDate {
            closeDate = calendar.date(byAdding: .day, value: 1, to: closeDate)!
        }
        
        // Check if the current time is outside the open hours
        return now < openDate || now >= closeDate
    }
    
    func getMostVotedWaitTime(barId: Int) async throws {
        let votes = try await BarNetworkManager.shared.fetchVoteSummaries().filter { $0.bar == barId }
        var countMap: [String: Int] = [:]
        votes.forEach { vote in
            countMap[vote.waitTime, default: 0] += 1
        }
        
        guard var status = self.statuses.first(where: { $0.bar == barId }) else {
            print("No status found for bar \(barId)")
            throw APIError.noUser
        }
        status.waitTime = countMap.max(by: { $0.value < $1.value })?.key ?? "<5 min"
        try await BarNetworkManager.shared.putBarStatus(status)

    }
}

extension BarViewModel {
    static let PREVIEW: BarViewModel = {
        let viewModel = BarViewModel()
        viewModel.bars = Bar.sampleBars
        return viewModel
    }()
}
