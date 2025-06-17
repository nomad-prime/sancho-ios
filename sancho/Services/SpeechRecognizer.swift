import AVFAudio
import AVFoundation
import Foundation
import Speech

@MainActor
protocol SpeechRecognizerProtocol {
    var transcribedTextPublisher: Published<String>.Publisher { get }
    var isListeningPublisher: Published<Bool>.Publisher { get }
    func checkAndRequestPermissions() async -> Bool
    func start() async throws
    func stop()
}

@MainActor
final class SpeechRecognizer: ObservableObject, SpeechRecognizerProtocol {
    @Published var transcribedText: String = ""
    @Published var isListening: Bool = false

    private let speechRecognizer = SFSpeechRecognizer(
        locale: Locale(identifier: "es-ES")
    )!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var transcribedTextPublisher: Published<String>.Publisher { $transcribedText }
    var isListeningPublisher: Published<Bool>.Publisher { $isListening }

    func checkAndRequestPermissions() async -> Bool {
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        guard speechStatus == .authorized else {
            return false
        }

        let granted = await withCheckedContinuation { continuation in
            if #available(iOS 17, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission {
                    granted in
                    continuation.resume(returning: granted)
                }
            }
        }
        return granted
    }

    func start() async throws {
        // Cancel any existing task
        recognitionTask?.cancel()
        recognitionTask = nil

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else {
            throw NSError(
                domain: "SpeechRecognizer",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Unable to create recognition request"
                ]
            )
        }
        recognitionRequest.shouldReportPartialResults = true

        // Configure session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(
            .record,
            mode: .measurement,
            options: .duckOthers
        )
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: recordingFormat
        ) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        isListening = true
        transcribedText = ""

        recognitionTask = speechRecognizer.recognitionTask(
            with: recognitionRequest
        ) { [weak self] result, error in
            guard let self else { return }

            if let result {
                self.transcribedText = result.bestTranscription.formattedString
                if result.isFinal {
                    self.stop()
                }
            }

            if error != nil {
                self.stop()
            }
        }
    }

    func stop() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest = nil
        recognitionTask = nil
        isListening = false
    }
}
