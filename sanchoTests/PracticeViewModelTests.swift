import XCTest

@testable import AmigoSancho

@MainActor
final class MockSpeechRecognizer: SpeechRecognizerProtocol {
    @Published var transcribedText: String = ""
    @Published var isListening: Bool = false

    var transcribedTextPublisher: Published<String>.Publisher { $transcribedText }
    var isListeningPublisher: Published<Bool>.Publisher { $isListening }

    var permissionGranted: Bool
    var didStart = false
    var didStop = false

    init(permissionGranted: Bool) {
        self.permissionGranted = permissionGranted
    }

    func checkAndRequestPermissions() async -> Bool {
        permissionGranted
    }

    func start() async throws {
        didStart = true
        isListening = true
    }

    func stop() {
        didStop = true
        isListening = false
    }
}

@MainActor
final class PracticeViewModelTests: XCTestCase {

    func test_initialMessages_containsSanchoGreeting() {
        let vm = PracticeViewModel(
            speechRecognizer: MockSpeechRecognizer(permissionGranted: true)
        )
        XCTAssertEqual(vm.messages.count, 1)
        XCTAssertEqual(
            vm.messages[0].text,
            "¡Hola! Soy Sancho. Vamos a practicar un poco de español."
        )
        XCTAssertFalse(vm.messages[0].isCurrentUser)
    }

    func test_transcribedTextPublisher_appendsMessage() {
        let mock = MockSpeechRecognizer(permissionGranted: true)
        let vm = PracticeViewModel(speechRecognizer: mock)

        // Simulate recognizer finishing speech
        mock.transcribedText = "Hola, Sancho!"
        mock.isListening = false

        // Give Combine a moment to propagate (unit test hack)
        RunLoop.main.run(until: Date())

        XCTAssertTrue(vm.messages.contains {
            $0.text == "Hola, Sancho!" && $0.isCurrentUser
        })
    }

    func test_micButtonTapped_starts_and_stopsListening() async {
        let mock = MockSpeechRecognizer(permissionGranted: true)
        let vm = PracticeViewModel(speechRecognizer: mock)

        XCTAssertFalse(vm.isListening)
        XCTAssertFalse(mock.didStart)

        // Tap mic → should start listening
        await vm.micButtonTapped()
        XCTAssertTrue(vm.isListening)
        XCTAssertTrue(mock.didStart)
        XCTAssertFalse(mock.didStop)

        // Tap again → should stop listening
        await vm.micButtonTapped()
        XCTAssertFalse(vm.isListening)
        XCTAssertTrue(mock.didStop)
    }

    func test_micButtonTapped_showsPermissionAlertWhenDenied() async {
        let mock = MockSpeechRecognizer(permissionGranted: false)
        let vm = PracticeViewModel(speechRecognizer: mock)

        XCTAssertFalse(vm.showPermissionAlert)

        await vm.micButtonTapped()

        XCTAssertTrue(vm.showPermissionAlert)
    }
}
