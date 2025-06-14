import SwiftUI

struct SanchoUITestScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: SanchoTheme.spacing * 2) {
                Text("SanchoUI Component Showcase")
                    .font(.largeTitle)
                    .padding(.bottom, SanchoTheme.spacing * 2)

                // SanchoAvatar
                Text("SanchoAvatar:").font(.headline)
                SanchoAvatar()
                    .padding(.bottom, SanchoTheme.spacing)

                // SanchoButton
                Text("SanchoButton:").font(.headline)
                SanchoButton(title: "Primary Button") {
                    print("Primary Button tapped")
                }
                SanchoButton(title: "Button with Icon", icon: Image(systemName: "star.fill")) {
                    print("Icon Button tapped")
                }
                .padding(.bottom, SanchoTheme.spacing)

                // SanchoBubble
                Text("SanchoBubble:").font(.headline)
                SanchoBubble(text: "Hello, this is an AI message.", isCurrentUser: false)
                SanchoBubble(text: "Hi, this is a user message!", isCurrentUser: true)
                SanchoBubble(text: "A slightly longer AI message to see how the bubble handles wrapping of text content.", isCurrentUser: false)
                SanchoBubble(text: "A user message that is also a bit longer for testing purposes.", isCurrentUser: true)
                    .padding(.bottom, SanchoTheme.spacing)

                // SanchoMicButton
                Text("SanchoMicButton:").font(.headline)
                SanchoMicButton()
                    .padding(.bottom, SanchoTheme.spacing)

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SanchoUITestScreen()
}
