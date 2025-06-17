import XCTest
import Combine // Ensure Combine is imported
import AVFoundation // Ensure AVFoundation is imported for AVSpeechSynthesisVoice
@testable import AmigoSancho

@MainActor
final class MockSpeechRecognizer: SpeechRecognizerProtocol {
    // Use PassthroughSubjects for more direct control in tests
    let transcribedTextSubject = PassthroughSubject<String, Never>()
    var transcribedTextPublisher: AnyPublisher<String, Never> {
        transcribedTextSubject.eraseToAnyPublisher()
    }

    let isListeningSubject = PassthroughSubject<Bool, Never>()
    var isListeningPublisher: AnyPublisher<Bool, Never> {
        isListeningSubject.eraseToAnyPublisher()
    }

    var permissionGranted: Bool
    var startCallCount = 0
    var stopCallCount = 0
    var currentListeningState = false // Internal state to help simulate

    init(permissionGranted: Bool) {
        self.permissionGranted = permissionGranted
    }

    func checkAndRequestPermissions() async -> Bool {
        permissionGranted
    }

    func start() async throws {
        startCallCount += 1
        currentListeningState = true
        isListeningSubject.send(true)
    }

    func stop() {
        stopCallCount += 1
        currentListeningState = false
        isListeningSubject.send(false)
    }
}

@MainActor
final class PracticeViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var viewModel: PracticeViewModel!
    var mockSpeechRecognizer: MockSpeechRecognizer!

    override func setUp() {
        super.setUp()
        cancellables = []
        mockSpeechRecognizer = MockSpeechRecognizer(permissionGranted: true)
        viewModel = PracticeViewModel(speechRecognizer: mockSpeechRecognizer)
    }

    override func tearDown() {
        viewModel = nil
        mockSpeechRecognizer = nil
        cancellables = nil
        super.tearDown()
    }

    func test_initialMessages_containsSanchoGreeting() {
        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertEqual(
            viewModel.messages[0].text,
            "¡Hola! Soy Sancho. Vamos a practicar un poco de español."
        )
        XCTAssertFalse(viewModel.messages[0].isCurrentUser)
    }

    func test_sendUserMessageAndHandleAIResponse_success() async {
        let userMessage = "Hola"
        // Initial Sancho greeting + user message + AI response
        let expectedMessageCount = 3

        // Expectation for the AI response to be added
        let expectation = XCTestExpectation(description: "AI response received")

        viewModel.$messages
            .dropFirst() // Ignore initial message
            .sink { messages in
                if messages.count >= expectedMessageCount {
                    if let lastMessage = messages.last, !lastMessage.isCurrentUser, lastMessage.text == "Claro, ¿en qué puedo ayudarte?" {
                        expectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)

        await viewModel.sendUserMessageAndHandleAIResponse(userText: userMessage)

        await fulfillment(of: [expectation], timeout: 3.0) // Increased timeout for safety

        XCTAssertEqual(viewModel.messages.count, expectedMessageCount)
        XCTAssertTrue(viewModel.messages.contains { $0.text == "Claro, ¿en qué puedo ayudarte?" && !$0.isCurrentUser })
    }

    // Note: Testing the error case for sendUserMessageAndHandleAIResponse where the placeholder
    // `Task.sleep` itself throws is not straightforward without modifying the ViewModel
    // to inject errors. This test assumes the happy path for the placeholder.
    // A real network layer would have injectable error states.

    func test_transcribedText_triggersUserMessageAndAIResponse() async {
        let transcribed = "Hola, ¿cómo estás?"
        // Initial Sancho greeting + user message + AI response
        let expectedTotalMessages = 3

        // Expectation for the AI response (last message)
        let aiResponseExpectation = XCTestExpectation(description: "AI response after transcription")

        viewModel.$messages
            .dropFirst(viewModel.messages.count) // Only interested in new messages
            .sink { newMessages in
                // We are waiting for two messages: user's and AI's
                if newMessages.count >= 2 { // User's message + AI's message
                    if let lastMessage = self.viewModel.messages.last,
                       !lastMessage.isCurrentUser,
                       lastMessage.text == "Claro, ¿en qué puedo ayudarte?" {
                        aiResponseExpectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)

        // 1. Simulate speech recognizer having transcribed text
        mockSpeechRecognizer.transcribedTextSubject.send(transcribed)

        // 2. Simulate user finishing speaking
        mockSpeechRecognizer.isListeningSubject.send(false) // This should trigger the chain

        await fulfillment(of: [aiResponseExpectation], timeout: 5.0) // Wait for AI response

        XCTAssertEqual(viewModel.messages.count, expectedTotalMessages, "Should be initial + user + AI message")

        XCTAssertTrue(viewModel.messages.contains { msg in
            msg.text == transcribed && msg.isCurrentUser
        }, "User message should be present")

        XCTAssertTrue(viewModel.messages.contains { msg in
            msg.text == "Claro, ¿en qué puedo ayudarte?" && !msg.isCurrentUser
        }, "AI response should be present")

        XCTAssertEqual(viewModel.transcribedText, "", "Transcribed text should be cleared after processing")
    }


    func test_micButtonTapped_startsListening_whenPermitted() async {
        mockSpeechRecognizer.permissionGranted = true
        await viewModel.micButtonTapped() // Tap to start
        XCTAssertTrue(viewModel.isListening)
        XCTAssertEqual(mockSpeechRecognizer.startCallCount, 1)
        XCTAssertEqual(mockSpeechRecognizer.stopCallCount, 0)
    }

    func test_micButtonTapped_stopsListening_whenActive() async {
        // Start listening first
        mockSpeechRecognizer.permissionGranted = true
        await viewModel.micButtonTapped() // Tap to start
        XCTAssertTrue(viewModel.isListening)
        XCTAssertEqual(mockSpeechRecognizer.startCallCount, 1)

        await viewModel.micButtonTapped() // Tap to stop
        XCTAssertFalse(viewModel.isListening)
        XCTAssertEqual(mockSpeechRecognizer.stopCallCount, 1)
    }

    func test_micButtonTapped_showsPermissionAlert_whenDenied() async {
        mockSpeechRecognizer.permissionGranted = false
        await viewModel.micButtonTapped()
        XCTAssertTrue(viewModel.showPermissionAlert)
        XCTAssertFalse(viewModel.isListening)
        XCTAssertEqual(mockSpeechRecognizer.startCallCount, 0)
    }
}
