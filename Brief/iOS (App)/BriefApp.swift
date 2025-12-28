//
//  BriefApp.swift
//  Brief (iOS)
//
//  iOS app entry point using SwiftUI
//

import SwiftUI

@main
struct BriefApp: App {
    @StateObject private var userPreferences = UserPreferences.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userPreferences)
        }
    }
}
