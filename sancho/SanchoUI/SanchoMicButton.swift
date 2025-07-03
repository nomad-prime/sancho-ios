import SwiftUI

struct SanchoMicButton: View {
    @Binding var isListening: Bool
    var action: () -> Void

    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(systemName: "mic.fill")
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    isListening
                    ? SanchoTheme.accentColor : SanchoTheme.primaryColor
                )
                .clipShape(Circle())
                .scaleEffect(isListening ? 1.1 : 1.0)
                .animation(
                    isListening
                    ? .easeInOut(duration: 0.5).repeatForever(
                        autoreverses: true
                    ) : .default,
                    value: isListening
                )
        }.accessibilityIdentifier("Sancho Mic Button")
    }
}

#if DEBUG
struct SanchoMicButton_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var isListening = false
        var body: some View {
            SanchoMicButton(
                isListening: $isListening,
                action: {
                    print("Mic button tapped in preview")
                    isListening.toggle()
                }
            )
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}
#endif
