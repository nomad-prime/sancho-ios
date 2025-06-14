import SwiftUI

struct PracticeView: View {
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        SanchoBubble(text: "¡Hola! Soy Sancho. Let's practice!", isCurrentUser: false)
                        SanchoBubble(text: "Hola Sancho!", isCurrentUser: true)
                    }
                    .padding()
                }

                Spacer()

                SanchoMicButton()
                    .frame(width: 80, height: 80) // Explicitly set frame as in issue example
                    .padding(.bottom, 20)
            }
            .navigationTitle("Sancho Chat")
        }
    }
}

#Preview {
    PracticeView()
}
