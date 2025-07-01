//
//  sanchoApp.swift
//  sancho
//
//  Created by Armin Ghajar Jazi on 03.06.25.
//

import SwiftUI
import SwiftData

@main
struct SanchoApp: App {
    @State private var isAuthenticated = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LearningSession.self,
            UserProgress.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                PracticeView()
            } else {
                AuthenticationView(isAuthenticated: $isAuthenticated)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
