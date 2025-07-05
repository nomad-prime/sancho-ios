import AVFAudio
import AVFoundation
import Combine
import Speech
import SwiftUI

@MainActor
final class PracticeViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var cancellables = Set<AnyCancellable>()
    private let speechRecognizer: SpeechRecognizerProtocol
    private let chatService: ChatServiceProtocol
    private let ttsService: TTSServiceProtocol
    private var audioPlayer: AVAudioPlayer?

    @Published var showPermissionAlert: Bool = false
    @Published var isListening: Bool = false
    @Published var transcribedText: String = ""
    @Published var isSpeaking: Bool = false
    @Published var messages: [ChatMessage] = [
        ChatMessage(
            text: "¡Hola! Soy Sancho. Vamos a practicar un poco de español.",
            isCurrentUser: false
        )
    ]

    init(
        speechRecognizer: SpeechRecognizerProtocol,
        chatService: ChatServiceProtocol,
        ttsService: TTSServiceProtocol
    ) {
        self.speechRecognizer = speechRecognizer
        self.chatService = chatService
        self.ttsService = ttsService
        super.init()
        self.speechRecognizer.transcribedTextPublisher
            .dropFirst()
            .sink { [weak self] newText in
                guard let self else { return }
                self.transcribedText = newText
                if !newText.isEmpty && !self.isListening {
                    self.messages.append(
                        ChatMessage(text: newText, isCurrentUser: true)
                    )
                    Task { await self.fetchAssistantReply() }
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

    private func fetchAssistantReply() async {
        let currentMessages = messages
        let newMessage = ChatMessage(text: "", isCurrentUser: false)
        messages.append(newMessage)
        let messageID = newMessage.id

        do {
            let stream = chatService.chatStream(messages: currentMessages)
            var accumulated = ""
            for try await chunk in stream {
                accumulated += chunk
                if let index = messages.firstIndex(where: { $0.id == messageID }) {
                    messages[index].text = accumulated
                }
            }
            await speak(text: accumulated)
        } catch {
            if let index = messages.firstIndex(where: { $0.id == messageID }) {
                messages[index].text = "(Error: \(error.localizedDescription))"
            }
        }
    }

    func speakLastMessage() async {
        guard let last = messages.last(where: { !$0.isCurrentUser }) else { return }
        await speak(text: last.text)
    }
    
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }

    private func speak(text: String) async {
        if isSpeaking {
            audioPlayer?.stop()
            isSpeaking = false
        }

        do {
            let data = try await ttsService.synthesizeSpeech(text: text, voiceId: nil)
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isSpeaking = true
        } catch {
            print("TTS error: \(error)")
        }
    }
}
