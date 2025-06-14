import SwiftUI

struct SanchoMicButton: View {
    @Binding var isListening: Bool
    var action: () -> Void

    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(systemName: "mic.fill")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 80, height: 80)
                .background(
                    isListening
                        ? SanchoTheme.accentColor : SanchoTheme.primaryColor
                )
                .clipShape(Circle())
                .scaleEffect(isListening ? 1.2 : 1.0)
                // Ensure animation value tracks isListening
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

// Preview needs to be updated to provide binding and action
// For the purpose of this subtask, the preview can be commented out or updated if straightforward.
// Example of updated Preview:

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
