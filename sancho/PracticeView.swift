import SwiftUI

struct PracticeView: View {
    @StateObject private var viewModel = PracticeViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            SanchoBubble(
                                text: message.text,
                                isCurrentUser: message.isCurrentUser
                            )
                        }
                    }
                    .padding()
                }

                Spacer()

                if !viewModel.transcribedText.isEmpty
                    || viewModel.isListening
                {
                    Text(
                        viewModel.transcribedText.isEmpty
                            ? "Listening..."
                            : viewModel.transcribedText
                    )
                    .padding()
                    .foregroundColor(
                        viewModel.isListening ? .gray : .black
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                SanchoMicButton(
                    isListening: $viewModel.isListening
                ) {
                    viewModel.micButtonTapped()
                }
                .frame(width: 80, height: 80)
                .padding(.bottom, 20)
            }
            .navigationTitle("Sancho Chat")
            .alert(
                "Permissions Required",
                isPresented: $viewModel.showPermissionAlert
            ) {
                Button("Open Settings") {
                    if let url = URL(
                        string: UIApplication.openSettingsURLString
                    ),
                        UIApplication.shared.canOpenURL(url)
                    {
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
