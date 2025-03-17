//
//  BarBuddyApp.swift
//  BarBuddy
//
//  Created by Jessica Lilja on 2/5/25.
//

import SwiftUI

@main
struct BarBuddyApp: App {
    var mapViewModel = MapViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mapViewModel)
        }
    }
}
