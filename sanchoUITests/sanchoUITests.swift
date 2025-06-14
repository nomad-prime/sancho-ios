import XCTest

final class sanchoUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // It's good practice to reset launch arguments for each test if needed,
        // or set them if your app behaves differently during UI tests.
        // app.launchArguments.append("--uitesting")
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testWelcomeMessageIsDisplayedAfterLogin() throws {
        // On AuthenticationView
        let simulateLoginButton = app.buttons["Simulate Login"]
        XCTAssertTrue(simulateLoginButton.waitForExistence(timeout: 5), "The 'Simulate Login' button should exist on the AuthenticationView.")
        simulateLoginButton.tap()

        // Now on HomeView (within ContentView's TabView)
        // Check for the navigation title of HomeView first.
        let homeNavigationTitle = app.navigationBars["Sancho's Home"].staticTexts["Sancho's Home"]
        XCTAssertTrue(homeNavigationTitle.waitForExistence(timeout: 5), "The Home screen with navigation title 'Sancho's Home' should be displayed after login.")

        // Then check for the welcome message itself.
        let welcomeMessage = app.staticTexts["¡Hola! I'm Sancho - Your AI Spanish learning companion"]
        XCTAssertTrue(welcomeMessage.waitForExistence(timeout: 5), "The welcome message should be displayed on the Home screen.")
    }

    @MainActor
    func testTabNavigationFlow() throws {
        // 1. Login
        let simulateLoginButton = app.buttons["Simulate Login"]
        XCTAssertTrue(simulateLoginButton.waitForExistence(timeout: 5), "The 'Simulate Login' button must exist to start the navigation test.")
        simulateLoginButton.tap()

        // 2. Verify Home tab is initially selected and its title is correct
        // The navigationBar identifier is its title.
        let homeNavBar = app.navigationBars["Sancho's Home"]
        XCTAssertTrue(homeNavBar.waitForExistence(timeout: 5), "The Home screen (identified by navigation bar 'Sancho's Home') should be visible initially.")

        // 3. Navigate to Learn tab and verify its title
        let learnTabButton = app.tabBars.buttons["Learn"] // Assumes tab bar buttons are identified by their labels
        XCTAssertTrue(learnTabButton.exists, "The 'Learn' tab bar button should exist.")
        learnTabButton.tap()

        let learnNavBar = app.navigationBars["Learn with Sancho"]
        XCTAssertTrue(learnNavBar.waitForExistence(timeout: 5), "The Learn screen (identified by navigation bar 'Learn with Sancho') should be displayed after tapping the 'Learn' tab.")

        // 4. Navigate to Practice tab and verify its title
        let practiceTabButton = app.tabBars.buttons["Practice"]
        XCTAssertTrue(practiceTabButton.exists, "The 'Practice' tab bar button should exist.")
        practiceTabButton.tap()

        let practiceNavBar = app.navigationBars["Practice with Sancho"]
        XCTAssertTrue(practiceNavBar.waitForExistence(timeout: 5), "The Practice screen (identified by navigation bar 'Practice with Sancho') should be displayed after tapping the 'Practice' tab.")

        // 5. Navigate to Profile tab and verify its title
        let profileTabButton = app.tabBars.buttons["Profile"]
        XCTAssertTrue(profileTabButton.exists, "The 'Profile' tab bar button should exist.")
        profileTabButton.tap()

        let profileNavBar = app.navigationBars["Your Sancho Profile"]
        XCTAssertTrue(profileNavBar.waitForExistence(timeout: 5), "The Profile screen (identified by navigation bar 'Your Sancho Profile') should be displayed after tapping the 'Profile' tab.")
    }
}
