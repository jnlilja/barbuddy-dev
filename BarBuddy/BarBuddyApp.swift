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
    @State private var voteViewModel = VoteViewModel()
    
    init() {
        loadRocketSimConnect()
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(mapViewModel)
                .environment(voteViewModel)
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
