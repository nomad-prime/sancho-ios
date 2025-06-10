import XCTest
import SwiftData
import Combine // For expectations
@testable import sancho // Import your app module

class ConversationViewModelTests: XCTestCase {

    var viewModel: ConversationViewModel!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    @MainActor // Ensure modelContext and viewModel are accessed on main actor
    override func setUpWithError() throws {
        try super.setUpWithError()

        // 1. Create an in-memory ModelContainer
        let schema = Schema([LearningSession.self, ChatMessageData.self])
        // Ensure UserProgress is also in schema if LearningSession relates to it or if any part of VM touches it
        // let schema = Schema([LearningSession.self, ChatMessageData.self, UserProgress.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        modelContext = modelContainer.mainContext // Use the main context directly

        // 2. Instantiate ConversationViewModel with this context
        // For simplicity, always start a new session for each test, or pass a specific one if needed.
        viewModel = ConversationViewModel(modelContext: modelContext, session: nil, sessionTopic: "Test Topic")
    }

    override func tearDownWithError() throws {
        viewModel = nil
        modelContext = nil
        modelContainer = nil
        try super.tearDownWithError()
    }

    @MainActor
    func testInitialGreetingMessage() throws {
        XCTAssertFalse(viewModel.messages.isEmpty, "ViewModel should have initial messages.")
        let firstMessage = viewModel.messages.first
        XCTAssertNotNil(firstMessage, "First message should exist.")
        XCTAssertFalse(firstMessage!.isUser, "First message should be from Sancho (AI).")
        XCTAssertTrue(firstMessage!.text.contains("Hello! I'm Sancho."), "First message should be a greeting.")

        // Check SwiftData
        let descriptor = FetchDescriptor<ChatMessageData>()
        let storedMessages = try modelContext.fetch(descriptor)
        XCTAssertEqual(storedMessages.count, 1, "One greeting message should be saved to SwiftData.")
        XCTAssertEqual(storedMessages.first?.text, firstMessage?.text)
    }

    @MainActor
    func testSendUserMessageAndSimulatedResponse() throws {
        let initialMessageCount = viewModel.messages.count
        let userMessageText = "Hola Sancho"

        // Expectation for AI response
        let responseExpectation = expectation(description: "Wait for AI response")

        var cancellable: AnyCancellable?
        cancellable = viewModel.$messages
            .dropFirst(1) // Ignore initial message + user message, wait for AI
            .sink { messages in
                if messages.count >= initialMessageCount + 2 { // User + AI
                    if let lastMessage = messages.last, !lastMessage.isUser {
                        responseExpectation.fulfill()
                    }
                }
            }

        viewModel.sendTextMessage(text: userMessageText)

        // Check user message immediately
        XCTAssertEqual(viewModel.messages.count, initialMessageCount + 1, "User message should be added to UI.")
        let lastUIMessage = viewModel.messages.last
        XCTAssertTrue(lastUIMessage?.isUser ?? false, "Last UI message should be from user.")
        XCTAssertEqual(lastUIMessage?.text, userMessageText, "User message text mismatch.")

        // Wait for AI response (with timeout)
        waitForExpectations(timeout: 3.0) { error in
            if let error = error {
                XCTFail("Expectation failed with error: \(error)")
            }
        }
        cancellable?.cancel() // Clean up subscriber

        XCTAssertEqual(viewModel.messages.count, initialMessageCount + 2, "AI response should be added.")
        let aiResponseMessage = viewModel.messages.last
        XCTAssertFalse(aiResponseMessage?.isUser ?? true, "Last message should be from AI.")
        XCTAssertTrue(aiResponseMessage!.text.contains("Simulated AI:"), "AI response text is incorrect.")

        // Check SwiftData
        let descriptor = FetchDescriptor<ChatMessageData>(sortBy: [SortDescriptor(\.timestamp)])
        let storedMessages = try modelContext.fetch(descriptor)

        // Initial greeting + user message + AI response
        XCTAssertEqual(storedMessages.count, 1 + 2, "Total messages in SwiftData should be 3.")
        XCTAssertEqual(storedMessages[1].text, userMessageText)
        XCTAssertTrue(storedMessages[1].isUser)
        XCTAssertEqual(storedMessages[2].text, aiResponseMessage?.text)
        XCTAssertFalse(storedMessages[2].isUser)
    }

    @MainActor
    func testStartStopListeningState() {
        // Simulate speech permission granted for this test
        viewModel.speechPermissionStatus = .authorized

        viewModel.startListening()
        XCTAssertTrue(viewModel.isListening, "ViewModel should be in listening state after startListening().")

        viewModel.stopListening()
        // stopListening has an async dispatch, need a slight delay or expectation
        let stopExpectation = expectation(description: "Wait for stopListening to complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Corresponds to delay in stopListening
            stopExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)

        XCTAssertFalse(viewModel.isListening, "ViewModel should not be in listening state after stopListening().")
    }

    @MainActor
    func testSimulatedNetworkError() {
        // This test relies on the random chance of the error.
        // To make it deterministic, we'd need a debug flag in ViewModel or a way to inject randomness.
        // For now, we'll try a few times. If it doesn't occur, the test won't strictly fail but won't verify the error.
        // A better approach is to use a debug method as suggested: `viewModel.triggerSimulatedNetworkError()`

        viewModel.triggerSimulatedNetworkError() // Use the debug method

        XCTAssertNotNil(viewModel.simulatedNetworkError, "Simulated network error should be set.")
        XCTAssertFalse(viewModel.isProcessing, "isProcessing should be false when network error occurs.")

        // Ensure sending another message clears the error (if AI response part is not hit due to error)
        let previousError = viewModel.simulatedNetworkError
        viewModel.sendTextMessage(text: "Test after error") // This might or might not hit AI response

        // If sendTextMessage clears the error at the beginning
        if viewModel.simulatedNetworkError != previousError {
             XCTAssertNil(viewModel.simulatedNetworkError, "Error should be cleared on new message send attempt if it was set.")
        }
    }

    @MainActor
    func testSpeechPermissionDenied() {
        viewModel.speechPermissionStatus = .denied
        viewModel.startListening()
        XCTAssertFalse(viewModel.isListening, "isListening should remain false if speech permission is denied.")
        XCTAssertNotNil(viewModel.speechRecognizerError, "Error message should be set if permission denied.")
    }

    @MainActor
    func testFinalizeSession() {
        let initialSession = viewModel.currentSession
        XCTAssertNotNil(initialSession, "Current session should exist.")
        let initialEndTime = initialSession?.endTime

        viewModel.finalizeSession()

        XCTAssertNotNil(viewModel.currentSession?.endTime, "Session end time should be set.")
        XCTAssertNotEqual(initialEndTime, viewModel.currentSession?.endTime, "End time should have changed.")

        // Verify in SwiftData (refetch or check existing instance)
        if let sessionId = initialSession?.id {
            let descriptor = FetchDescriptor<LearningSession>(predicate: #Predicate { $0.id == sessionId })
            let fetchedSessions = try? modelContext.fetch(descriptor)
            XCTAssertEqual(fetchedSessions?.count, 1, "Session should be found in SwiftData.")
            XCTAssertNotNil(fetchedSessions?.first?.endTime, "Fetched session should have an end time.")
        }
    }
}
