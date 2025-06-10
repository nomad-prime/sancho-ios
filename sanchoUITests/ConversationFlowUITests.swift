import XCTest

final class ConversationFlowUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        // Note: Consider adding launch arguments/environment variables
        // to bypass authentication or set up specific states if needed.
        // e.g., app.launchArguments = ["-UITesting", "-BypassAuth"]
    }

    func testNavigateToConversationScreenAndVerifyTitle() throws {
        let app = XCUIApplication()
        app.launch() // Launch the app

        // Assuming the app launches to ContentView where 'Learn' tab is visible
        // Adjust if there's an authentication flow first.
        // If auth is needed, you might need:
        // if app.buttons["LoginScreenButton"].exists { app.buttons["LoginScreenButton"].tap() }

        // Tap the "Learn" tab. Adjust identifier if needed.
        // If tabs are identified by text:
        app.tabBars.buttons["Learn"].tap() // Assuming tab bar button is labeled "Learn"

        // Tap the "Start Speaking Practice" button.
        // Ensure this button has a clear accessibility identifier or label.
        // If it's just text:
        let startPracticeButton = app.buttons["Start Speaking Practice"]
        XCTAssertTrue(startPracticeButton.waitForExistence(timeout: 5), "Start Speaking Practice button should exist.")
        startPracticeButton.tap()

        // Verify that the "Sancho Chat" navigation title exists.
        XCTAssertTrue(app.navigationBars["Sancho Chat"].waitForExistence(timeout: 5), "Sancho Chat navigation title should appear.")
    }

    func testMicrophoneButtonInteraction() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Learn"].tap()

        let startPracticeButton = app.buttons["Start Speaking Practice"]
        XCTAssertTrue(startPracticeButton.waitForExistence(timeout: 5))
        startPracticeButton.tap()

        XCTAssertTrue(app.navigationBars["Sancho Chat"].waitForExistence(timeout: 5))

        // Find the microphone button by its accessibility label.
        let micButtonInitialLabel = "Start listening"
        let micButtonStopLabel = "Stop listening"

        let micButton = app.buttons[micButtonInitialLabel]
        XCTAssertTrue(micButton.waitForExistence(timeout: 5), "Microphone button should exist with label '\(micButtonInitialLabel)'.")

        // Tap to start listening
        micButton.tap()

        // Check if the button's label changes to "Stop listening"
        // Or check for the "Listening..." text if that's more reliable/testable
        // For label change, the element itself might change, so re-query or use the new label.
        let stopMicButton = app.buttons[micButtonStopLabel]
        XCTAssertTrue(stopMicButton.waitForExistence(timeout: 2), "Microphone button label should change to '\(micButtonStopLabel)'.")

        // Check for "Listening: " text (if it's an accessibility element)
        // This requires the Text view to be identifiable.
        // Let's assume the button state change is the primary check for now.

        // Tap to stop listening
        stopMicButton.tap()

        // Check if the button's label reverts to "Start listening"
        XCTAssertTrue(micButton.waitForExistence(timeout: 2), "Microphone button label should revert to '\(micButtonInitialLabel)'.")
    }

    // testSendTextMessageAndSeeResponse() is complex for pure UI testing without direct text input.
    // This would typically involve:
    // 1. Tapping mic button.
    // 2. Using SFSpeechRecognizer's testing capabilities (if available) or a mock to simulate voice input.
    // 3. Tapping mic button again to stop.
    // 4. Verifying user message bubble appears.
    // 5. Waiting and verifying AI message bubble appears.
    // For now, this test is omitted as it requires more infrastructure than typically available in basic UI tests.
    // A simpler version might check if *any* messages appear after interaction if the ViewModel is seeded.
}
