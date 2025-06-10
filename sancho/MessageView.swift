import SwiftUI

// Assuming Message struct is available from ConversationViewModel.swift or a shared scope.
// It should include: id: UUID, text: String, isUser: Bool, timestamp: Date

struct MessageView: View {
    let message: Message // Input: The message object

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.isUser {
                Spacer()

                Text(message.text)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
                    // Accessibility for user message
                    .accessibilityElement(children: .combine) // Combine Text content for label
                    .accessibilityLabel("Your message: \(message.text), sent at \(message.timestamp.formatted(date: .omitted, time: .shortened))")
                    .accessibilitySortPriority(1) // Higher priority for content

            } else {
                Image(systemName: "person.crop.circle.fill") // Sancho's avatar
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
                    .accessibilityHidden(true) // Decorative, as sender is announced in the message label

                Text(message.text)
                    .padding(12)
                    .background(Color(UIColor.systemGray5))
                    .foregroundColor(Color(UIColor.label))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.width * 0.70, alignment: .leading)
                    // Accessibility for Sancho's message
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Sancho's message: \(message.text), received at \(message.timestamp.formatted(date: .omitted, time: .shortened))")
                    .accessibilitySortPriority(1)

                Spacer(minLength: UIScreen.main.bounds.width * 0.1)
            }
        }
        .id(message.id) // Important for ScrollViewReader
        // Apply accessibility to the HStack to treat the whole bubble as one element for navigation
        // This is an alternative to setting it on the Text views, depending on desired VoiceOver behavior.
        // For this case, combining at the Text level with specific labels is likely better.
        // However, if the HStack itself should be a single focusable element:
        // .accessibilityElement(children: .combine) // Could be .ignore if children are fully accessible
        // .accessibilityLabel(message.isUser ? "Your message: \(message.text)" : "Sancho's message: \(message.text)" + ", at \(message.timestamp.formatted(date: .omitted, time: .shortened))")
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessageView(message: Message(id: UUID(), text: "Hello, this is a message from Sancho the assistant.", isUser: false, timestamp: Date()))
                .padding()
                .previewLayout(.sizeThatFits)
                .environment(\.colorScheme, .light)

            MessageView(message: Message(id: UUID(), text: "Hi Sancho! This is my reply. It might be a bit longer to see how it wraps.", isUser: true, timestamp: Date().addingTimeInterval(60)))
                .padding()
                .previewLayout(.sizeThatFits)
                .environment(\.colorScheme, .light)

            MessageView(message: Message(id: UUID(), text: "Another message from Sancho.", isUser: false, timestamp: Date().addingTimeInterval(120)))
                .padding()
                .previewLayout(.sizeThatFits)
                .environment(\.colorScheme, .dark)

            MessageView(message: Message(id: UUID(), text: "User's dark mode reply.", isUser: true, timestamp: Date().addingTimeInterval(180)))
                .padding()
                .previewLayout(.sizeThatFits)
                .environment(\.colorScheme, .dark)
        }
    }
}
