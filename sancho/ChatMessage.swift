import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    var text: String
    var isCurrentUser: Bool
}
