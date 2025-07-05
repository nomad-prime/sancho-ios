import SwiftUI

struct SanchoGoogleButton: View {
    enum Variant {
        case logo
        case continueWithGoogle
    }

    let variant: Variant
    let action: () -> Void

    init(variant: Variant, action: @escaping () -> Void) {
        self.variant = variant
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Group {
                switch variant {
                case .logo:
                    Image("GoogleLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                case .continueWithGoogle:
                    Image("ContinueWithGoogle")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                }
            }
            .padding(0)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.clear, lineWidth: 1)
            )
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SanchoGoogleButton(variant: .logo) {
            print("Tapped logo-only")
        }

        SanchoGoogleButton(variant: .continueWithGoogle) {
            print("Tapped continue with Google")
        }
    }
    .padding()
}
