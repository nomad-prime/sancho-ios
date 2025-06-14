import SwiftUI

struct SanchoButton: View {
    let title: String
    let icon: Image?
    let action: () -> Void

    init(title: String, icon: Image? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    icon
                }
                Text(title)
            }
            .padding()
            .frame(minHeight: 44)
            .foregroundColor(.white)
            .background(SanchoTheme.primaryColor)
            .cornerRadius(SanchoTheme.cornerRadius)
        }
    }
}

#Preview {
    VStack {
        SanchoButton(title: "Primary Action") {
            print("Primary Action tapped")
        }
        SanchoButton(title: "Settings", icon: Image(systemName: "gear")) {
            print("Settings tapped")
        }
    }
    .padding()
}
