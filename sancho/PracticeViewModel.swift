import AVFAudio
import AVFoundation
import Combine
import Speech
import SwiftUI

@MainActor
final class PracticeViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let speechRecognizer: SpeechRecognizerProtocol
    private let synthesizer = AVSpeechSynthesizer()

    @Published var showPermissionAlert: Bool = false
    @Published var isListening: Bool = false
    @Published var transcribedText: String = ""
    @Published var messages: [ChatMessage] = [
        ChatMessage(
            text: "¡Hola! Soy Sancho. Vamos a practicar un poco de español.",
            isCurrentUser: false
        )
    ]

    init(speechRecognizer: SpeechRecognizerProtocol) {
        self.speechRecognizer = speechRecognizer
        self.speechRecognizer.transcribedTextPublisher
            .dropFirst()
            .sink { [weak self] newText in
                guard let self else { return }
                self.transcribedText = newText
                if !newText.isEmpty && !self.isListening {
                    let finalText = newText
                    self.messages.append(
                        ChatMessage(text: finalText, isCurrentUser: true)
                    )
                    self.transcribedText = "" // Clear the live transcript
                    Task {
                        await self.sendUserMessageAndHandleAIResponse(userText: finalText)
                    }
                }
            }
            .store(in: &cancellables)

        self.speechRecognizer.isListeningPublisher
            .sink { [weak self] newState in
                self?.isListening = newState
            }.store(in: &cancellables)
    }

    // MARK: - Public Methods

    func micButtonTapped() async {

        if self.isListening {
            speechRecognizer.stop()
        } else {
            let granted = await speechRecognizer.checkAndRequestPermissions()
            if granted {
                try? await speechRecognizer.start()
            } else {
                showPermissionAlert = true
            }
        }
    }

    func sendUserMessageAndHandleAIResponse(userText: String) async {
        // Simulate network request
        do {
            // Placeholder for actual network call
            // For now, simulate a delay and return a canned response
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            let aiResponse = "Claro, ¿en qué puedo ayudarte?" // Canned Spanish response

            messages.append(ChatMessage(text: aiResponse, isCurrentUser: false))
            speak(text: aiResponse)
        } catch {
            let errorMessage = "Error: Unable to reach AI. Please try again."
            messages.append(ChatMessage(text: errorMessage, isCurrentUser: false))
        }
    }

    // MARK: - Private Helpers

    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-ES")
        utterance.rate = 0.5 // Learner-friendly speed

        synthesizer.speak(utterance)
    }
}
