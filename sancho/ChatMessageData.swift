import Foundation
import SwiftData

@Model
final class ChatMessageData {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var text: String
    var isUser: Bool

    // Relationship: Each message belongs to one session
    var session: LearningSession? // Inverse relationship defined in LearningSession

    init(id: UUID = UUID(), timestamp: Date = Date(), text: String, isUser: Bool, session: LearningSession? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.text = text
        self.isUser = isUser
        self.session = session
    }
}
