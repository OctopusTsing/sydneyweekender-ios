//
//  sydweekender_iosApp.swift
//  sydweekender-ios
//

import SwiftUI
import SwiftData

@main
struct sydweekender_iosApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SavedItinerary.self,
            CheckInRecord.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        // Force VenueDatabase to load on startup
        _ = VenueDatabase.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
