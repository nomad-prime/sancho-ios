import SwiftUI
import Speech
import AVFoundation

struct ChatMessage: Identifiable {
    let id = UUID()
    var text: String
    var isCurrentUser: Bool
}

struct PracticeView: View {
    @State private var isListening: Bool = false
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))!
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var transcribedText: String = "" // To hold live transcription
    @State private var showPermissionAlert: Bool = false // For showing permission denial alert
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "¡Hola! Soy Sancho. Let's practice!", isCurrentUser: false),
        ChatMessage(text: "Hola Sancho!", isCurrentUser: true)
    ]

    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            // Handle permission result later
            print("Microphone permission granted: \(granted)")
        }
    }

    func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // Handle permission result later
            print("Speech recognition authorization status: \(authStatus)")
        }
    }

    func startSpeechRecognition() {
        // Reset previous task and request if any
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true

        // Check Speech Recognition Authorization
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                guard authStatus == .authorized else {
                    self.showPermissionAlert = true // Or handle specific statuses
                    print("Speech recognition not authorized.")
                    // Potentially call requestSpeechRecognitionPermission() again or guide user
                    return
                }

                // Check Microphone Permission
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    OperationQueue.main.addOperation {
                        guard granted else {
                            self.showPermissionAlert = true
                            print("Microphone permission not granted.")
                            // Potentially call requestMicrophonePermission() again or guide user
                            return
                        }

                        // Configure Audio Session
                        let audioSession = AVAudioSession.sharedInstance()
                        do {
                            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                        } catch {
                            print("audioSession properties weren't set because of an error.")
                            self.isListening = false
                            return
                        }

                        // Setup Audio Engine and Input
                        let inputNode = self.audioEngine.inputNode
                        let recordingFormat = inputNode.outputFormat(forBus: 0)
                        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
                            self.recognitionRequest?.append(buffer)
                        }

                        self.audioEngine.prepare()
                        do {
                            try self.audioEngine.start()
                        } catch {
                            print("audioEngine couldn't start because of an error.")
                            self.isListening = false
                            return
                        }

                        self.isListening = true
                        self.transcribedText = "" // Clear previous transcription

                        // Start Recognition Task
                        self.recognitionTask = self.speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                            var isFinal = false
                            if let result = result {
                                self.transcribedText = result.bestTranscription.formattedString
                                isFinal = result.isFinal
                            }

                            if error != nil || isFinal {
                                self.audioEngine.stop()
                                inputNode.removeTap(onBus: 0)
                                self.recognitionRequest = nil
                                self.recognitionTask = nil
                                self.isListening = false // Update listening state

                                // Handle final recognized text (e.g., add to chat)
                                if isFinal, error == nil {
                                    let finalText = self.transcribedText
                                    if !finalText.isEmpty {
                                        let newMessage = ChatMessage(text: finalText, isCurrentUser: true)
                                        self.messages.append(newMessage)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func stopSpeechRecognition() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio() // Indicate that audio is complete
        }
        recognitionTask?.cancel() // Cancel the task
        recognitionTask = nil
        recognitionRequest = nil
        isListening = false
        print("Speech recognition stopped by user.")
    }

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(messages) { message in
                            SanchoBubble(text: message.text, isCurrentUser: message.isCurrentUser)
                        }
                    }
                    .padding()
                }

                Spacer()

                if !transcribedText.isEmpty || isListening { // Show if listening or if there's text from recent listening
                    Text(transcribedText.isEmpty ? "Listening..." : transcribedText)
                        .padding()
                        .foregroundColor(isListening ? .gray : .black) // Differentiate live vs final display if needed
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                SanchoMicButton(isListening: $isListening, action: {
                    if self.isListening {
                        self.stopSpeechRecognition()
                    } else {
                        self.startSpeechRecognition()
                    }
                })
                    .frame(width: 80, height: 80) // Explicitly set frame as in issue example
                    .padding(.bottom, 20)
            }
            .navigationTitle("Sancho Chat")
            .alert("Permissions Required", isPresented: $showPermissionAlert) {
                Button("Open Settings") {
                    // Action to open app settings
                    if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                    showPermissionAlert = false // Dismiss alert
                }
                Button("Cancel", role: .cancel) {
                    showPermissionAlert = false // Dismiss alert
                }
            } message: {
                Text("Sancho needs access to your microphone and speech recognition to practice your Spanish. Please grant these permissions in Settings.")
            }
        }
    }
}

#Preview {
    PracticeView()
}
