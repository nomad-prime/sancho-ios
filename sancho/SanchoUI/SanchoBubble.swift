import SwiftUI

struct SanchoBubble: View {
    let text: String
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            Text(text)
                .padding()
                .foregroundColor(isCurrentUser ? .white : .primary)
                .background(isCurrentUser ? SanchoTheme.primaryColor : Color(UIColor.systemGray5))
                .cornerRadius(16.0)
            if !isCurrentUser {
                Spacer()
            }
        }
        .padding(isCurrentUser ? .leading : .trailing, 20) 
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 10) {
        SanchoBubble(text: "Hello from AI!", isCurrentUser: false)
        SanchoBubble(text: "Hi there! This is a slightly longer message to see how it wraps.", isCurrentUser: true)
        SanchoBubble(text: "Another message from the AI.", isCurrentUser: false)
    }
    .padding()
}
