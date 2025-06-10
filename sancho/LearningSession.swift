import Foundation
import SwiftData

@Model
final class LearningSession {
    var startTime: Date
    var endTime: Date
    var topic: String
    var wordsLearned: [String] // SwiftData can handle arrays of simple types

    init(startTime: Date = Date(), endTime: Date = Date(), topic: String = "", wordsLearned: [String] = []) {
        self.startTime = startTime
        self.endTime = endTime
        self.topic = topic
        self.wordsLearned = wordsLearned
    }
}
