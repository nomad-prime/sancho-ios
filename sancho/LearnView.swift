import SwiftUI

struct LearnView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()

                Text("Ready to practice your Spanish?")
                    .font(.title2)
                    .multilineTextAlignment(.center)

                NavigationLink(destination: PracticeView()) {
                    SanchoButton(title: "Start Speaking Practice") { }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Learn with Sancho")
        }
    }
}
