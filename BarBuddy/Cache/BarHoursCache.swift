//
//  BarHoursCache.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/24/25.
//

import Foundation

// May keep this for now till I start implementing URL response caching
actor BarHoursCache {
    
    static let shared = BarHoursCache(maxSize: 100) // Set your max cache size

    /// Dictionary storing cached `BarHours` objects, keyed by bar ID.
    private var cache: [Int: BarHours] = [:]
    /// Array tracking the access order of bar IDs for LRU eviction.
    private var accessOrder: [Int] = []
    /// Maximum number of items the cache can hold.
    private let maxSize: Int

    /// Initializes the cache with a specified maximum size.
    /// - Parameter maxSize: The maximum number of items to store in the cache.
    init(maxSize: Int) {
        self.maxSize = maxSize
    }

    /// Retrieves a `BarHours` object for a given bar ID, updating its position as most recently used.
    /// - Parameter barId: The unique identifier for the bar.
    /// - Returns: The cached `BarHours` object, or `nil` if not found.
    func get(for barId: Int) -> BarHours? {
        if let _ = cache[barId] {
            // Move accessed ID to the end (most recently used)
            accessOrder.removeAll { $0 == barId }
            accessOrder.append(barId)
        }
        return cache[barId]
    }

    /// Inserts or updates a `BarHours` object in the cache for a given bar ID.
    /// If the cache exceeds its maximum size, the least recently used item is evicted.
    /// - Parameters:
    ///   - BarHours: The `BarHours` object to cache.
    ///   - barId: The unique identifier for the bar.
    func set(value BarHours: BarHours, forKey barId: Int) {
        if cache[barId] == nil && cache.count >= maxSize {
            // Evict least recently used
            if let oldest = accessOrder.first {
                cache.removeValue(forKey: oldest)
                accessOrder.removeFirst()
            }
        }
        cache[barId] = BarHours
        accessOrder.removeAll { $0 == barId }
        accessOrder.append(barId)
    }

    /// Removes a cached `BarHours` object for a given bar ID.
    /// - Parameter barId: The unique identifier for the bar.
    func remove(for barId: Int) {
        cache.removeValue(forKey: barId)
        accessOrder.removeAll { $0 == barId }
    }

    /// Clears all cached items and resets the access order.
    func clear() {
        cache.removeAll()
        accessOrder.removeAll()
    }
}
