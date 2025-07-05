import SwiftUI

struct IntroCardView: View {
    @Binding var isAuthenticated: Bool

    var body: some View {
        VStack {
            Spacer()

            HStack {
                VStack(spacing: 24) {
                    Text("Start the Journey")
                        .font(.sanchoTitle)
                        .foregroundColor(.black)

                    Text("Learn a new language with\n your trusted companion, Sancho")
                        .font(.sanchoRegular)
                        .multilineTextAlignment(.center)

                    AuthenticationView(isAuthenticated: $isAuthenticated)
                }
                .padding(28)
                .padding(.horizontal, 4)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(SanchoTheme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: SanchoTheme.cornerRadius)
                        .stroke(Color.primary, lineWidth: 1)
                )
            }
            .padding(.horizontal, 6)
        }
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    StatefulPreviewWrapper(false) { isAuthenticated in
        IntroCardView(isAuthenticated: isAuthenticated)
    }
}
