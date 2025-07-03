import SwiftUI

struct SanchoSpeakerButton: View {
    @Binding var isSpeaking: Bool
    var action: () -> Void

    @State private var pulse = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "speaker.wave.3")
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(SanchoTheme.primaryColor)
                .clipShape(Circle())
                .scaleEffect(pulse ? 1.1 : 1.0)
                .animation(
                    isSpeaking
                        ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                        : .default,
                    value: pulse
                )
        }
        .accessibilityIdentifier("Sancho Speaker Button")
        .onAppear {
            if isSpeaking { pulse = true }
        }
        .onChange(of: isSpeaking) { newValue in
            pulse = newValue
        }
    }
}

#if DEBUG
struct SanchoSpeakerButton_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var isSpeaking = true
        var body: some View {
            SanchoSpeakerButton(isSpeaking: $isSpeaking) {
                print("Speaker tapped")
                isSpeaking.toggle()
            }
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
