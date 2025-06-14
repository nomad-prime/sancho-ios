import SwiftUI

struct LearnView: View {
    @State private var isPracticeActive = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                Text("Ready to practice your Spanish?")
                    .font(.title2)
                    .multilineTextAlignment(.center)

                SanchoButton(title: "Start Speaking Practice") {
                    isPracticeActive = true
                }.accessibilityIdentifier("Start Speaking Practice")


                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $isPracticeActive) {
                PracticeView()
            }
            .navigationTitle("Learn with Sancho")
        }
    }
}

#Preview {
    LearnView()
}
