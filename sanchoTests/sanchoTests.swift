//
//  sanchoTests.swift
//  sanchoTests
//
//  Created by Armin Ghajar Jazi on 03.06.25.
//

import Testing
import SwiftData
@testable import sancho // Ensure your main app target is importable
import Foundation

@Suite struct ModelTests {

    var modelContext: ModelContext

    init() {
        // Create an in-memory model container for testing
        let schema = Schema([LearningSession.self, UserProgress.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = ModelContext(container)
        } catch {
            fatalError("Failed to create in-memory model container: \(error)")
        }
    }

    @Test func testLearningSessionInitialization() {
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(3600) // 1 hour later
        let topic = "Colors"
        let words = ["rojo", "azul", "verde"]

        let session = LearningSession(startTime: startTime, endTime: endTime, topic: topic, wordsLearned: words)

        #expect(session.startTime == startTime)
        #expect(session.endTime == endTime)
        #expect(session.topic == topic)
        #expect(session.wordsLearned == words)
        #expect(session.wordsLearned.count == 3)
    }

    @Test func testLearningSessionDefaultInitialization() {
        let session = LearningSession()
        // Check that default values are not nil or empty if they shouldn't be,
        // or are empty/default if that's the expectation.
        // For Date, it will be approximately Date(), so direct comparison is tricky.
        // Check if it's recent enough.
        #expect(abs(session.startTime.timeIntervalSinceNow) < 5) // Within 5 seconds
        #expect(abs(session.endTime.timeIntervalSinceNow) < 5)   // Within 5 seconds
        #expect(session.topic == "")
        #expect(session.wordsLearned.isEmpty)
    }

    @Test func testUserProgressInitialization() {
        let progress = UserProgress(currentLevel: 2, totalWordsLearned: 50, completedSessions: [])

        #expect(progress.currentLevel == 2)
        #expect(progress.totalWordsLearned == 50)
        #expect(progress.completedSessions != nil)
        #expect(progress.completedSessions?.isEmpty == true)
    }

    @Test func testUserProgressDefaultInitialization() {
        let progress = UserProgress()
        #expect(progress.currentLevel == 1)
        #expect(progress.totalWordsLearned == 0)
        #expect(progress.completedSessions != nil)
        #expect(progress.completedSessions?.isEmpty == true)
    }

    @Test func testUserProgressAddingSession() throws {
        let progress = UserProgress()
        modelContext.insert(progress) // Insert into context to manage relationship

        let session1 = LearningSession(topic: "Greetings", wordsLearned: ["hola", "adiós"])
        modelContext.insert(session1) // Also insert session if it's an independent entity

        // If completedSessions is nil (due to optional init), initialize it
        if progress.completedSessions == nil {
            progress.completedSessions = []
        }
        progress.completedSessions?.append(session1)

        #expect(progress.completedSessions?.count == 1)
        #expect(progress.completedSessions?.first?.topic == "Greetings")

        let session2 = LearningSession(topic: "Numbers", wordsLearned: ["uno", "dos"])
        modelContext.insert(session2)
        progress.completedSessions?.append(session2)

        #expect(progress.completedSessions?.count == 2)
        #expect(progress.completedSessions?.last?.topic == "Numbers")

        // Verify persistence if desired (fetch request)
        // This might be more of an integration test for SwiftData itself
        let descriptor = FetchDescriptor<UserProgress>()
        let fetchedProgressItems = try modelContext.fetch(descriptor)
        let fetchedProgress = fetchedProgressItems.first
        #expect(fetchedProgress?.completedSessions?.count == 2)
    }
}
