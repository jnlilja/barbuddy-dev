//
//  BarBuddyApp.swift
//  BarBuddy
//
//  Created by Jessica Lilja on 2/5/25.
//

import SwiftUI
// import FirebaseCore


// so that firebase is connnected when the app starts 
// class AppDelegate: NSObject, UIApplicationDelegate {
//   func application(_ application: UIApplication,
//                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//     FirebaseApp.configure()

//     return true
//   }
// }


@main
struct BarBuddyApp: App {
    var mapViewModel = MapViewModel()
    
    
    // @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mapViewModel)
        }
    }
}
