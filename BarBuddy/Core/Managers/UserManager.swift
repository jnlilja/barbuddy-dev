import Foundation
import FirebaseAuth

class UserManager {
    static let shared = UserManager()
    private let cache = NSCache<NSString, User>()
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    
    private init() {
        cache.countLimit = 100 // Maximum number of users to cache
    }
    
    func getUser() async throws -> User {
        // Check cache first
        if let cachedUser = cache.object(forKey: "current_user" as NSString) {
            return cachedUser
        }
        
        // Fetch from API
        let user = try await GetUserAPIService.shared.getUserInfo()
        
        // Cache the result
        cache.setObject(user, forKey: "current_user" as NSString)
        
        // Set up cache invalidation
        Task {
            try await Task.sleep(nanoseconds: UInt64(cacheTimeout * 1_000_000_000))
            cache.removeObject(forKey: "current_user" as NSString)
        }
        
        return user
    }
    
    func updateUser(_ user: User) {
        cache.setObject(user, forKey: "current_user" as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    func getUserById(_ id: String) async throws -> User {
        // Check cache first
        if let cachedUser = cache.object(forKey: id as NSString) {
            return cachedUser
        }
        
        // Fetch from API
        let user = try await GetUserAPIService.shared.getUserById(id)
        
        // Cache the result
        cache.setObject(user, forKey: id as NSString)
        
        // Set up cache invalidation
        Task {
            try await Task.sleep(nanoseconds: UInt64(cacheTimeout * 1_000_000_000))
            cache.removeObject(forKey: id as NSString)
        }
        
        return user
    }
} 