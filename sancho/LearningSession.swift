import Foundation
import SwiftData

@Model
final class LearningSession {
    var startTime: Date
    var endTime: Date
    var topic: String
    var wordsLearned: [String] // SwiftData can handle arrays of simple types
    var messageCount: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \ChatMessageData.session)
    var messages: [ChatMessageData]? = []

    init(startTime: Date = Date(), endTime: Date = Date(), topic: String = "", wordsLearned: [String] = [], messageCount: Int = 0, messages: [ChatMessageData]? = []) {
        self.startTime = startTime
        self.endTime = endTime
        self.topic = topic
        self.wordsLearned = wordsLearned
        self.messageCount = messageCount
        self.messages = messages
    }
}
