import SwiftUI
import Speech
import SwiftData

struct ConversationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: ConversationViewModel

    // State for animations
    @State private var isPulsingMic: Bool = false
    @State private var isPulsingSpeaker: Bool = false

    init(session: LearningSession? = nil, topic: String = "General Conversation") {
        _viewModel = StateObject(wrappedValue: ConversationViewModel(modelContext: modelContext, session: session, sessionTopic: topic))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Error Banners
            if let networkErrorMessage = viewModel.simulatedNetworkError {
                ErrorBannerView(message: networkErrorMessage, type: .network)
            } else if let speechErrorMessage = viewModel.speechRecognizerError {
                ErrorBannerView(message: speechErrorMessage, type: .speech)
            } else if viewModel.speechPermissionStatus == .denied || viewModel.speechPermissionStatus == .restricted {
                ErrorBannerView(message: "Speech recognition or microphone access is currently denied or restricted. Please go to Settings > Privacy to enable access for Sancho.", type: .permission)
            }

            // Message List
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageView(message: message)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .onChange(of: viewModel.messages) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                .accessibilityLabel("Conversation messages")
            }

            // Transcribed Text
            if viewModel.isListening && !viewModel.transcribedText.isEmpty {
                Text("Listening: \(viewModel.transcribedText)...")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(.gray)
                    .font(.caption)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Transcribed text while listening: \(viewModel.transcribedText)")
                    .accessibilityLiveRegion(.assertive)
            }

            // Input Area - Microphone Button
            HStack {
                Spacer() // Center the button
                ZStack {
                    Image(systemName: "mic.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45) // Base icon size
                        .foregroundColor(.white)
                        .padding(20) // Padding to make the tap area larger and for background
                        .background(viewModel.isListening ? Color.red : Color.blue)
                        .clipShape(Circle())
                        .scaleEffect(viewModel.isListening ? 1.2 : 1.0)
                        .opacity(viewModel.isListening && isPulsingMic ? 0.7 : 1.0)
                        .shadow(radius: 5)
                        .onAppear { // For initial pulse state, if already listening
                            if viewModel.isListening {
                                startMicPulsingAnimation()
                            }
                        }

                    if viewModel.isProcessing && !viewModel.isListening {
                        ProgressView()
                            .scaleEffect(1.5) // Make spinner larger
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(width: 80, height: 80) // Match button size
                            .background(Color.black.opacity(0.3)) // Dim background
                            .clipShape(Circle())
                    }
                }
                .frame(width: 80, height: 80) // Explicit frame for the ZStack
                .accessibilityElement(children: .ignore) // Ignore ZStack itself, use button below
                .accessibilityLabel(viewModel.isListening ? "Stop listening" : (viewModel.isProcessing ? "Processing your speech" : "Start listening"))
                .accessibilityHint(viewModel.isProcessing ? "" : "Tap to start or stop voice input.")
                .accessibilityAddTraits(viewModel.isListening ? .isSelected : [])
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if viewModel.isListening {
                            viewModel.stopListening()
                            stopMicPulsingAnimation()
                        } else if !viewModel.isProcessing { // Don't allow start if already processing something else
                            if viewModel.simulatedNetworkError != nil {
                                 viewModel.simulatedNetworkError = nil
                            }
                            viewModel.startListening()
                            startMicPulsingAnimation()
                        }
                    }
                }
                .disabled(viewModel.speechPermissionStatus != .authorized && viewModel.speechPermissionStatus != nil && !viewModel.isProcessing)

                Spacer() // Center the button
            }
            .padding(.vertical, 20) // More vertical padding for the larger button
            .background(Color(UIColor.systemGray6))
            // Instructional text removed as per previous task, button is self-descriptive
        }
        .navigationTitle("Sancho Chat")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModel.stopListening()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Learn")
                    }
                }
                .accessibilityLabel("Back to Learn screen")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.isSpeaking {
                    Image(systemName: "waveform")
                        .foregroundColor(.blue)
                        .opacity(isPulsingSpeaker ? 0.5 : 1.0)
                        .onAppear(perform: startSpeakerPulsingAnimation)
                        .onDisappear(perform: stopSpeakerPulsingAnimation)
                        .accessibilityLabel("Sancho is speaking")
                }
            }
        }
        .onAppear {
            if viewModel.speechPermissionStatus == nil {
                 viewModel.requestSpeechPermissions()
            }
        }
        .onDisappear {
            viewModel.finalizeSession()
            stopMicPulsingAnimation() // Ensure animations are stopped
            stopSpeakerPulsingAnimation()
        }
        .onChange(of: viewModel.isListening) { _, isListening in
            if isListening {
                startMicPulsingAnimation()
            } else {
                stopMicPulsingAnimation()
            }
        }
        .onChange(of: viewModel.isSpeaking) { _, isSpeaking in
            if isSpeaking {
                startSpeakerPulsingAnimation()
            } else {
                stopSpeakerPulsingAnimation()
            }
        }
    }

    func startMicPulsingAnimation() {
        isPulsingMic = false // Reset to ensure animation starts correctly
        withAnimation(Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
            isPulsingMic = true
        }
    }

    func stopMicPulsingAnimation() {
        withAnimation { // Stop animation smoothly
            isPulsingMic = false
        }
    }

    func startSpeakerPulsingAnimation() {
        isPulsingSpeaker = false
        withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            isPulsingSpeaker = true
        }
    }

    func stopSpeakerPulsingAnimation() {
        withAnimation {
            isPulsingSpeaker = false
        }
    }
}

// ErrorBannerView (assuming it's correctly defined from previous step)
enum ErrorBannerType { /* ... as defined before ... */
    case network, speech, permission
    var color: Color { switch self { case .network: return .orange; case .speech: return .red; case .permission: return .yellow } }
    var systemImageName: String { switch self { case .network: return "wifi.exclamationmark"; case .speech: return "exclamationmark.bubble.fill"; case .permission: return "lock.fill" } }
}
struct ErrorBannerView: View { /* ... as defined before ... */
    let message: String; let type: ErrorBannerType
    var body: some View { HStack { Image(systemName: type.systemImageName).foregroundColor(type.color); Text(message).font(.footnote).foregroundColor(type.color) }.padding(8).frame(maxWidth: .infinity).background(type.color.opacity(0.15)).cornerRadius(8).padding(.horizontal).accessibilityElement(children: .combine).accessibilityLabel("Error: \(message)").accessibilityLiveRegion(.assertive) }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        do {
            let schema = Schema([LearningSession.self, ChatMessageData.self, UserProgress.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: config)
            return NavigationView { ConversationView(session: nil, topic: "Preview Topic").modelContainer(container) }
        } catch { return Text("Failed to create preview: \(error.localizedDescription)") }
    }
}
