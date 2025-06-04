//
//  BarViewModel.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 6/1/25.
//
import Foundation

@MainActor
@Observable
final class BarViewModel: Mockable {
    var bars: Bars = []
    var statuses: [BarStatus] = []
    var hours: [BarHours] = []
    var networkManager: NetworkMockable
    
    init(networkManager: NetworkMockable = BarNetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func loadBarData() async {
        async let fetchedStatuses = networkManager.fetchStatuses()
        async let fetchedBars = networkManager.fetchAllBars()
        async let fetchedHours = networkManager.fetchAllBarHours()

        do {
            self.statuses = try await fetchedStatuses
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            handleNetworkError(error, context: "Bar Status GET")
        } catch let apiError as APIError {
            handleAPIError(apiError, context: "Bar Status GET")
        } catch {
            print("Bar Status GET ERROR - \(error)")
        }
        
        do {
            self.bars = try await fetchedBars
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            handleNetworkError(error, context: "Bar GET")
        } catch let apiError as APIError {
            handleAPIError(apiError, context: "Bar GET")
        } catch {
            print("Bar GET ERROR - \(error)")
        }
        
        do {
            self.hours = try await fetchedHours
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            handleNetworkError(error, context: "Bar Hours GET")
        } catch let apiError as APIError {
            handleAPIError(apiError, context: "Bar Hours GET")
        } catch {
            print("Bar Hours GET ERROR - \(error)")
        }
    }
    
    // Function to fetch the bar's hours
    func getHours(for bar: Bar) async throws -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        // Try to get from cache
        if var cached = await BarHoursCache.shared.get(for: bar.id) {
            guard
                let openTime = cached.openTime,
                let closeTime = cached.closeTime
            else {
                print("One of the opening/closing times for bar \(bar.name) is missing.")
                throw BarViewModelError.hoursAreNil
            }
                
            // Get last cached status and check if it needs to be updated
            let previousClosedStatus = cached.isClosed
            let isCurrentlyClosed = isClosed(openTime, closeTime)
            
            // If the status has not changed, do not update
            guard previousClosedStatus != isCurrentlyClosed else {
                return "\(isCurrentlyClosed ? "Closed" : "Open"): \(formatter.string(from: openTime)) - \(formatter.string(from: closeTime))"
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
            return "\(isCurrentlyClosed ? "Closed" : "Open"): \(formatter.string(from: openTime)) - \(formatter.string(from: closeTime))"
        }
        // Fetch all hours if not in cache
        do {
            let allHours = try await networkManager.fetchAllBarHours()
            guard var hours = allHours.first(where: { $0.bar == bar.id }) else { return nil }
            
            guard
                let openTime = hours.openTime,
                let closeTime = hours.closeTime
            else {
                print("One of the times for \(bar.name) is nil.")
                throw BarViewModelError.hoursAreNil
            }
            
            // Cache all fetched hours
            for h in allHours {
                await BarHoursCache.shared.set(value: h, forKey: h.id)
            }
        
            let closed = isClosed(openTime, closeTime)
            hours.isClosed = closed
            
            // Patch hours and update cache
            do {
                try await networkManager.patchBarHours(id: hours.id)
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
            return "\(closed ? "Closed" : "Open"): \(formatter.string(from:openTime)) - \(formatter.string(from: closeTime))"
            
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
    
    func getMostVotedWaitTime(barId: Int) async throws {
        let votes = try await networkManager.fetchVoteSummaries().filter { $0.bar == barId }

        var countMap: [String: Int] = [:]
        votes.forEach { vote in
            countMap[vote.waitTime, default: 0] += 1
        }

        guard let index = self.statuses.firstIndex(where: { $0.bar == barId }) else {
            print("No status found for bar \(barId)")
            throw BarViewModelError.statusNotFound
        }

        let mostVotedTime = countMap.max(by: { $0.value < $1.value })?.key ?? "<5 min"
        self.statuses[index].waitTime = mostVotedTime

        try await networkManager.putBarStatus(self.statuses[index])
    }
    
    internal func isClosed(_ openTime: Date, _ closeTime: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // Today's date components
        var openComponents = calendar.dateComponents([.year, .month, .day], from: now)
        var closeComponents = openComponents

        // Extract open and close time parts
        let openHour = calendar.component(.hour, from: openTime)
        let openMinute = calendar.component(.minute, from: openTime)
        let closeHour = calendar.component(.hour, from: closeTime)
        let closeMinute = calendar.component(.minute, from: closeTime)
        
        openComponents.hour = openHour
        openComponents.minute = openMinute
        
        closeComponents.hour = closeHour
        closeComponents.minute = closeMinute

        guard let openDate = calendar.date(from: openComponents),
              var closeDate = calendar.date(from: closeComponents) else {
            return true // Assume closed if dates can't be formed
        }
        
        // If close is earlier than open, assume it spills into next day
        if closeDate <= openDate {
            closeDate = calendar.date(byAdding: .day, value: 1, to: closeDate)!
        }
        
        // Return true if now is outside of the open-close window
        return now < openDate || now >= closeDate
    }
    
    
    private func handleAPIError(_ error: APIError, context: String) {
        print("\(context) ERROR:", terminator: " ")
        switch error {
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

extension BarViewModel {
    static let PREVIEW: BarViewModel = {
        let viewModel = BarViewModel()
        viewModel.bars = Bar.sampleBars
        return viewModel
    }()
}
