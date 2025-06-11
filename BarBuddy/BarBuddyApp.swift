//
//  BarBuddyApp.swift
//  BarBuddy
//
//  Created by Jessica Lilja on 2/5/25.
//

import SwiftUI
import Firebase

@main
struct BarBuddyApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        loadRocketSimConnect()
        FirebaseApp.configure()
        
        // Configure URLCache with increased memory and disk capacities
        // Optimized for image-heavy social networking app with frequent API calls
        let memoryCapacity = 200 * 1024 * 1024  // 200 MB (4x increase)
        let diskCapacity = 500 * 1024 * 1024    // 500 MB (5x increase)
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
        URLCache.shared = cache
        
        // Optional: Log cache configuration for debugging
        #if DEBUG
        print("📱 URLCache configured: Memory=\(memoryCapacity/1024/1024)MB, Disk=\(diskCapacity/1024/1024)MB")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}

/* Loads the RocketSim Connect framework for debugging purposes. This won't be included in production builds,
    but is a useful debugging tool.
 */
private func loadRocketSimConnect() {
    #if DEBUG
    guard (Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() == true) else {
        print("Failed to load linker framework")
        return
    }
    print("RocketSim Connect successfully linked")
    #endif
}

enum AppConfig {
    static var baseURL: String {
        guard let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String else {
            fatalError("❌ Missing API_BASE_URL in Info.plist")
        }
        return baseURL
    }
}
