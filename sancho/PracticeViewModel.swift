import SwiftUI
import AVFoundation
import Speech
import AVFAudio
import Combine

@MainActor
final class PracticeViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private var speechRecognizer = SpeechRecognizer()
    @Published var showPermissionAlert: Bool = false
    @Published var isListening: Bool = false
    @Published var transcribedText: String = ""
    @Published var messages: [ChatMessage] = [
        ChatMessage(text: "¡Hola! Soy Sancho. Vamos a practicar un poco de español.", isCurrentUser: false),
    ]

    init() {
        speechRecognizer.$transcribedText
            .dropFirst()
            .sink { [weak self] newText in
                guard let self else { return }
                self.transcribedText = newText
                if !newText.isEmpty && !self.speechRecognizer.isListening {
                    self.messages.append(ChatMessage(text: newText, isCurrentUser: true))
                }
            }
            .store(in: &cancellables)
        
        speechRecognizer.$isListening
            .sink { [weak self] newState in
                self?.isListening = newState
            }.store(in: &cancellables)
    }

    func micButtonTapped() {
        Task {
            if speechRecognizer.isListening {
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
}

