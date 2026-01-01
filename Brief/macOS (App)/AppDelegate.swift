//
//  AppDelegate.swift
//  macOS (App)
//
//  Created by Daniel Ensign on 8/14/25.
//

import SwiftUI

@main
struct BriefApp: App {
    @StateObject private var userPreferences = UserPreferences.shared
    
    var body: some Scene {
        WindowGroup {
            if userPreferences.hasCompletedOnboarding || !userPreferences.email.isEmpty {
                ContentView()
                    .environmentObject(userPreferences)
            } else {
                OnboardingView()
                    .environmentObject(userPreferences)
            }
        }
        .windowResizability(.contentSize)
        .windowStyle(DefaultWindowStyle())
    }
}
