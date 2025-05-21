//
//  BarHoursCache.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 5/20/25.
//

import Foundation

actor BarHoursCache {
    static let shared = BarHoursCache(maxSize: 100) // Set your max cache size

    private var cache: [Int: BarHours] = [:]
    private var accessOrder: [Int] = []
    private let maxSize: Int

    init(maxSize: Int) {
        self.maxSize = maxSize
    }

    func get(for barId: Int) -> BarHours? {
        if let _ = cache[barId] {
            // Move accessed ID to the end (most recently used)
            accessOrder.removeAll { $0 == barId }
            accessOrder.append(barId)
        }
        return cache[barId]
    }

    func set(_ barHours: BarHours, for barId: Int) {
        if cache[barId] == nil && cache.count >= maxSize {
            // Evict least recently used
            if let oldest = accessOrder.first {
                cache.removeValue(forKey: oldest)
                accessOrder.removeFirst()
            }
        }
        cache[barId] = barHours
        accessOrder.removeAll { $0 == barId }
        accessOrder.append(barId)
    }

    func remove(for barId: Int) {
        cache.removeValue(forKey: barId)
        accessOrder.removeAll { $0 == barId }
    }

    func clear() {
        cache.removeAll()
        accessOrder.removeAll()
    }

    // MARK: - Persistence

    private var cacheURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("BarHoursCache.json")
    }

    func saveToDisk() async throws {
        let data = try JSONEncoder().encode(cache)
        try data.write(to: cacheURL)
    }

    func loadFromDisk() async throws {
        let data = try Data(contentsOf: cacheURL)
        cache = try JSONDecoder().decode([Int: BarHours].self, from: data)
        accessOrder = Array(cache.keys)
    }
}
