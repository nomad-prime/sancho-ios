import SwiftUI

struct LearnView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Learn Screen")

                NavigationLink(destination: ConversationView()) {
                    Text("Start Speaking Practice")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Learn with Sancho")
        }
    }
}

#Preview {
    LearnView()
}
