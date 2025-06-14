import XCTest

final class PracticeViewUITests: XCTestCase {

    func testMicButtonAppears() throws {
        let app = XCUIApplication()
        app.launch()

        if app.buttons["Simulate Login"].exists {
            app.buttons["Simulate Login"].tap()
        }

        // Tap Learn tab
        let learnTab = app.tabBars.buttons["Learn"]
        XCTAssertTrue(learnTab.waitForExistence(timeout: 2))
        learnTab.tap()

        // Tap Start Speaking Practice
        let startButton = app.buttons["Start Speaking Practice"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 2))
        startButton.tap()

        // Assert mic button exists
        let micButton = app.buttons["Sancho Mic Button"]
        XCTAssertTrue(micButton.waitForExistence(timeout: 2))
    }

    func testMicButtonTogglesListeningState() throws {
        let app = XCUIApplication()
        app.launch()

        if app.buttons["Simulate Login"].exists {
            app.buttons["Simulate Login"].tap()
        }

        app.tabBars.buttons["Learn"].tap()
        app.buttons["Start Speaking Practice"].tap()

        let micButton = app.buttons["Sancho Mic Button"]
        XCTAssertTrue(micButton.waitForExistence(timeout: 2))

        micButton.tap()

        let listeningLabel = app.staticTexts["Listening..."]
        XCTAssertTrue(listeningLabel.waitForExistence(timeout: 3))
    }
}
