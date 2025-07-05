import SwiftUI

struct PracticeView: View {
    @StateObject private var viewModel: PracticeViewModel
    
    init() {
        let config = AppConfig.default
        let backend = BackendEnvironment(config: config)
        _viewModel = StateObject(
            wrappedValue: PracticeViewModel(
                speechRecognizer: SpeechRecognizer(),
                chatService: ChatService(backend: backend),
                ttsService: TTSService(backend: backend)
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(viewModel.messages) { message in
                                    SanchoBubble(
                                        text: message.text,
                                        isCurrentUser: message.isCurrentUser
                                    )
                                    .transition(
                                        .opacity
                                            .combined(
                                                with: .move(edge: .bottom)
                                            )
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 16)
                        }
                        .onChange(of: viewModel.messages.count) { _ in
                            if let last = viewModel.messages.last {
                                withAnimation {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }

                    Spacer()
                        .frame(height: 140) // reserve space for mic and buttons
                }

                VStack(spacing: 12) {
                    if !viewModel.transcribedText.isEmpty || viewModel.isListening {
                        Text(
                            viewModel.transcribedText.isEmpty
                            ? "Listening..."
                            : viewModel.transcribedText
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.thinMaterial, in: Capsule())
                        .foregroundColor(
                            viewModel.isListening ? .gray : .primary
                        )
                        .font(
                            .system(size: 16, weight: .medium, design: .rounded)
                        )
                        .transition(.opacity)
                    }

                    HStack(spacing: 32) {
                        SanchoMicButton(isListening: $viewModel.isListening) {
                            Task { await viewModel.micButtonTapped() }
                        }

                        SanchoSpeakerButton(isSpeaking: $viewModel.isSpeaking
                        ) {
                            Task { await viewModel.speakLastMessage() }
                        }
                    }.padding(.bottom, 24)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .alert(
                "Permissions Required",
                isPresented: $viewModel.showPermissionAlert
            ) {
                Button("Open Settings") {
                    if let url = URL(
                        string: UIApplication.openSettingsURLString
                    ),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                    viewModel.showPermissionAlert = false
                }
                Button("Cancel", role: .cancel) {
                    viewModel.showPermissionAlert = false
                }
            } message: {
                Text(
                    "Sancho needs access to your microphone and speech recognition to practice your Spanish. Please grant these permissions in Settings."
                )
            }
        }
    }
}

#Preview {
    PracticeView()
}
