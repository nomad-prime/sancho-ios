import AVFAudio
import AVFoundation
import Combine
import Speech
import SwiftUI

@MainActor
final class PracticeViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let speechRecognizer: SpeechRecognizerProtocol

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
                    self.messages.append(
                        ChatMessage(text: newText, isCurrentUser: true)
                    )
                }
            }
            .store(in: &cancellables)

        self.speechRecognizer.isListeningPublisher
            .sink { [weak self] newState in
                self?.isListening = newState
            }.store(in: &cancellables)
    }

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
}
