import SwiftUI
import Observation

@Observable
final class TimerManager {
    private let id: Int
    private var storageKey: String { "coolDownEndDate_\(id)" }
    private var storedEndDate: Double {
        get { UserDefaults.standard.double(forKey: storageKey) }
        set { UserDefaults.standard.set(newValue, forKey: storageKey) }
    }
    
    // Published end-date
    private var endDate: Date?
    
    var timeRemaining: TimeInterval {
        guard let endDate else { return 0 }
        return max(0, endDate.timeIntervalSinceNow)
    }
    
    var isActive: Bool { timeRemaining > 0 }

    /// Start a new 5-minute countdown (or custom duration)
    func start(duration: TimeInterval = 5 * 60) {
        endDate = Date().addingTimeInterval(duration)
        storedEndDate = endDate!.timeIntervalSince1970
    }
    
    /// Clear the countdown
    func reset() {
        endDate = nil
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    // MARK: - Init / restore
    
    init(id: Int) {
        self.id = id
        if storedEndDate > 0 {
            let restored = Date(timeIntervalSince1970: storedEndDate)
            if restored > Date() {
                endDate = restored
            } else {
                // The old countdown already expired
                storedEndDate = 0
            }
        }
    }
}
