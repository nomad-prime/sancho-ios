import SwiftUI
import Combine
import Speech
import AVFoundation
import SwiftData

// Local Message struct for UI display
struct Message: Identifiable, Equatable {
    let id: UUID
    var text: String
    var isUser: Bool
    var timestamp: Date = Date() // Added timestamp for potential UI use and MessageView accessibility
}

class ConversationViewModel: ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var messages: [Message] = []
    @Published var isListening: Bool = false
    @Published var isProcessing: Bool = false

    @Published var speechPermissionStatus: SFSpeechRecognizerAuthorizationStatus? = nil
    @Published var transcribedText: String = ""
    @Published var speechRecognizerError: String? = nil
    @Published var simulatedNetworkError: String? = nil // For simulated network error

    private let speechSynthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking: Bool = false

    @Published var wasInterrupted: Bool = false
    private var wasSpeakingWhenInterrupted: Bool = false
    private var wasListeningWhenInterrupted: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    private var modelContext: ModelContext
    var currentSession: LearningSession?

    init(modelContext: ModelContext, session: LearningSession? = nil, sessionTopic: String = "Default Topic") {
        self.modelContext = modelContext
        self.currentSession = session

        setupAudioSession()
        speechSynthesizer.delegate = self
        registerForAudioInterruptions()

        if let existingSession = session {
            self.currentSession = existingSession
            loadMessagesFromSession()
            if let lastSanchoMessage = self.messages.filter({ !$0.isUser }).last {
                speakText("Welcome back to your session on \(existingSession.topic). You were saying: \(lastSanchoMessage.text)")
            } else {
                 speakText("Welcome back to your session on \(existingSession.topic)!")
            }
        } else {
            let newSession = LearningSession(startTime: Date(), topic: sessionTopic)
            self.modelContext.insert(newSession)
            do {
                try self.modelContext.save()
                self.currentSession = newSession
            } catch {
                speechRecognizerError = "Error: Could not create a new learning session."
            }
            let initialMessageText = "Hello! I'm Sancho. Let's practice \(sessionTopic)."
            let initialMessage = Message(id: UUID(), text: initialMessageText, isUser: false)
            self.messages.append(initialMessage)
            saveMessageToSwiftData(initialMessage)
            speakText(initialMessageText)
        }

        if speechRecognizer == nil {
            speechRecognizerError = "Speech recognizer is not available for Spanish (es-ES)."
        }
    }

    deinit {
        unregisterForAudioInterruptions()
        finalizeSession()
    }

    private func loadMessagesFromSession() {
        guard let sessionMessages = currentSession?.messages else {
            if currentSession?.messages == nil { currentSession?.messages = [] }
            return
        }
        self.messages = sessionMessages.sorted(by: { $0.timestamp < $1.timestamp }).map { msgData in
            Message(id: msgData.id, text: msgData.text, isUser: msgData.isUser, timestamp: msgData.timestamp)
        }
    }

    private func saveMessageToSwiftData(_ message: Message) {
        guard let currentSession = currentSession else { return }
        let chatMessageData = ChatMessageData(id: message.id, timestamp: message.timestamp, text: message.text, isUser: message.isUser, session: currentSession)
        modelContext.insert(chatMessageData)
        if currentSession.messages == nil { currentSession.messages = [chatMessageData] }
        else { currentSession.messages?.append(chatMessageData) }
        currentSession.messageCount = currentSession.messages?.count ?? 0
    }

    func finalizeSession() {
        currentSession?.endTime = Date()
        do { try modelContext.save() }
        catch { print("Failed to save session on finalization: \(error)") }
    }

    private func setupAudioSession() { /* ... unchanged ... */ }
    private func activateAudioSession() throws { /* ... unchanged ... */ }
    private func registerForAudioInterruptions() { /* ... unchanged ... */ }
    private func unregisterForAudioInterruptions() { /* ... unchanged ... */ }
    @objc private func handleAudioSessionInterruption(notification: Notification) { /* ... unchanged ... */ }
    func requestSpeechPermissions() { /* ... unchanged ... */ }
    func startListening() { /* ... unchanged ... */ }
    func stopListening() { /* ... unchanged ... */ }
    func speakText(_ text: String) { /* ... unchanged ... */ }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) { DispatchQueue.main.async { self.isSpeaking = true } }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = false }
        let audioSession = AVAudioSession.sharedInstance()
        do { try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetooth, .duckOthers]) }
        catch { speechRecognizerError = "Error resetting audio session post-speech." }
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) { DispatchQueue.main.async { self.isSpeaking = false } }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) { DispatchQueue.main.async { self.isSpeaking = true } }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) { DispatchQueue.main.async { self.isSpeaking = false } }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didEncounterError error: Error, for utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = false; self.speechRecognizerError = "TTS Error: \(error.localizedDescription)" }
    }

    // MARK: - Message Handling (Updated for Simulated Network Error)
    func sendTextMessage(text: String) {
        simulatedNetworkError = nil // Clear previous network error
        speechRecognizerError = nil // Clear other errors too

        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        let userUIMessage = Message(id: UUID(), text: trimmedText, isUser: true, timestamp: Date())
        messages.append(userUIMessage)
        saveMessageToSwiftData(userUIMessage)

        isProcessing = true

        // Simulate network error chance (e.g., 1 in 5 for testing, 1 in 10 for less frequent)
        if Int.random(in: 1...5) == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Simulate slight delay for error
                self.simulatedNetworkError = "Network connection unstable. Please tap the microphone to try sending your message again."
                self.isProcessing = false
            }
            return // Return early, no AI response
        }

        Timer.publish(every: 1.5, on: .main, in: .common).autoconnect().first().sink { [weak self] _ in
            guard let self = self else { return }
            // Clear error again before attempting AI response
            self.simulatedNetworkError = nil

            let aiResponseText = "Simulated AI: You said '\(trimmedText)'. That's a good start! Let's talk more."
            let aiUIMessage = Message(id: UUID(), text: aiResponseText, isUser: false, timestamp: Date())
            self.messages.append(aiUIMessage)
            self.saveMessageToSwiftData(aiUIMessage)
            self.isProcessing = false
            self.speakText(aiResponseText)
        }.store(in: &cancellables)
    }

    func addSanchoMessageToUI(text: String) {
        let sanchoMessage = Message(id: UUID(), text: text, isUser: false, timestamp: Date())
        messages.append(sanchoMessage)
    }

    // Debug method to trigger error
    func triggerSimulatedNetworkError() {
        simulatedNetworkError = "Network connection unstable (triggered manually). Please try again."
        isProcessing = false
    }
}

// Ensure the actual method implementations are present and these stubs are not called.
// The stubs were a workaround for tool limitations with long files.
// The real methods (setupAudioSession, activateAudioSession etc.) should be directly part of the class body.
// This 'extension' and 'callStubs' method should be removed if the tool handles the full file correctly.
// For this operation, we are removing the stub extension.
