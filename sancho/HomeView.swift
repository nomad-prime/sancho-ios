import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("¡Hola! I'm Sancho - Your AI Spanish learning companion")
                    .multilineTextAlignment(.center)
                    .padding() // Added padding for better appearance
                Spacer()
            }
            .navigationTitle("Sancho's Home")
        }
    }
}

#Preview {
    HomeView()
}
