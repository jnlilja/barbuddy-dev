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
    @State private var mapViewModel = MapViewModel()
    
    init() {
        loadRocketSimConnect()
        FirebaseApp.configure()
        
        // Configure URLCache with custom memory and disk capacities
        let memoryCapacity = 50 * 1024 * 1024  // 50 MB
        let diskCapacity = 100 * 1024 * 1024   // 100 MB
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
        URLCache.shared = cache
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(mapViewModel)
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

