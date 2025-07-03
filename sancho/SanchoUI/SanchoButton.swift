import SwiftUI

struct SanchoButton: View {
    let title: String?
    let icon: Image?
    let action: () -> Void

    init(title: String? = nil, icon: Image? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    icon
                        .foregroundColor(.white)
                }
                if let title = title {
                    Text(title)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .background(SanchoTheme.primaryColor)
            .cornerRadius(SanchoTheme.cornerRadius)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SanchoButton(title: "Primary Action") {
            print("Primary Action tapped")
        }

        SanchoButton(title: "Settings", icon: Image(systemName: "gearshape")) {
            print("Settings tapped")
        }

        SanchoButton(icon: Image(systemName: "speaker.wave.2")) {
            print("Icon-only button tapped")
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
