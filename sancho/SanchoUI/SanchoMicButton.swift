import SwiftUI

struct SanchoMicButton: View {
    @State private var isListening: Bool = false

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) { // Animation for color and initial scale change
                isListening.toggle()
            }
        }) {
            Image(systemName: "mic.fill")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 80, height: 80)
                .background(isListening ? Color.red : SanchoTheme.primaryColor)
                .clipShape(Circle())
                .scaleEffect(isListening ? 1.2 : 1.0)
                .animation(isListening ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: isListening)
        }
    }
}

#Preview {
    SanchoMicButton()
}
