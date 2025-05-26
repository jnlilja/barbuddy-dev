//
//  BarBuddyApp.swift
//  BarBuddy
//
//  Created by Jessica Lilja on 2/5/25.
//

import SwiftUI
import Firebase
import FirebaseCore

@main
struct BarBuddyApp: App {
    @StateObject private var sessionManager = SessionManager()
    //@StateObject private var mapViewModel = MapViewModel()
    @StateObject private var tabManager = TabManager()
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        let searchField = UISearchBar.appearance()
        searchField.searchTextField.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        searchField.searchTextField.textColor = UIColor.white
        searchField.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search bars...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.7)]
        )
        searchField.searchTextField.leftView?.tintColor = UIColor.white.withAlphaComponent(0.7)
        searchField.tintColor = UIColor.white
        
        // Style the cancel button
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([
            .foregroundColor: UIColor.white
        ], for: .normal)
    }

    var body: some Scene {
        WindowGroup {
            switch sessionManager.sessionState {
            case .loggedIn:
                TabView(selection: $tabManager.selectedTab) {
//                    SwipeView()
//                        .tabItem {
//                            Image(systemName: "person.2.fill")
//                            Text("Swipe")
//                        }
//                        .tag(0)
//                    MessagesView()
//                        .tabItem {
//                            Image(systemName: "message.fill")
//                            Text("Messages")
//                        }
//                        .tag(1)

                    MainFeedView()
                        .tabItem {
                            Image(systemName: "map.fill")
                            Text("Map")
                        }
                        .tag(0)
//                    ProfileView()
//                        .tabItem {
//                            Image(systemName: "person.circle")
//                            Text("Profile")
//                        }
//                        .tag(4)
                }
                .accentColor(Color("Salmon"))
                //.environmentObject(mapViewModel)
                .environmentObject(sessionManager)
            case .loggedOut:
                LoginView()
                    .environmentObject(sessionManager)
            case .splash:
                SplashView()
                    .environmentObject(sessionManager)
            }
        }
    }
}
