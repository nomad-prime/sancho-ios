import SwiftUI

struct StartScreenView: View {
    @Binding var isAuthenticated: Bool

    var body: some View {
        ZStack {
            Image("StartScreenBackground")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                IntroCardView(isAuthenticated: $isAuthenticated)
                    .padding(.horizontal, 48)
            }
        }
    }
}

#Preview {
    StatefulPreviewWrapper(false) { isAuthenticated in
        StartScreenView(isAuthenticated: isAuthenticated)
    }
}
