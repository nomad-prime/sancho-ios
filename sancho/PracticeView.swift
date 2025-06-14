import AVFoundation
import SwiftUI
import Speech
import AVFAudio

struct ChatMessage: Identifiable {
    let id = UUID()
    var text: String
    var isCurrentUser: Bool
}

struct PracticeView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var showPermissionAlert: Bool = false
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "¡Hola! Soy Sancho. Let's practice!", isCurrentUser: false),
        ChatMessage(text: "Hola Sancho!", isCurrentUser: true)
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(messages) { message in
                            SanchoBubble(
                                text: message.text,
                                isCurrentUser: message.isCurrentUser
                            )
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                if !speechRecognizer.transcribedText.isEmpty || speechRecognizer.isListening {
                    Text(
                        speechRecognizer.transcribedText.isEmpty
                        ? "Listening..." : speechRecognizer.transcribedText
                    )
                    .padding()
                    .foregroundColor(speechRecognizer.isListening ? .gray : .black)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                SanchoMicButton(isListening: $speechRecognizer.isListening) {
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
                .frame(width: 80, height: 80)
                .padding(.bottom, 20)
            }
            .onChange(of: speechRecognizer.transcribedText) { newText in
                // When recognizer stops and there's final text, add it to messages
                if !newText.isEmpty && !speechRecognizer.isListening {
                    messages.append(ChatMessage(text: newText, isCurrentUser: true))
                }
            }
            .navigationTitle("Sancho Chat")
            .alert("Permissions Required", isPresented: $showPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                    showPermissionAlert = false
                }
                Button("Cancel", role: .cancel) {
                    showPermissionAlert = false
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
