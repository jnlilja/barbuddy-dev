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
    var mapViewModel = MapViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mapViewModel)
               
        }
    }
}
