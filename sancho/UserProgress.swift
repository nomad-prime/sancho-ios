import Foundation
import SwiftData

@Model
final class UserProgress {
    var currentLevel: Int
    var totalWordsLearned: Int

    // SwiftData can handle relationships.
    // If this is a one-to-many relationship, it might require @Relationship.
    // For now, a simple array should work for embedding or a simple relation.
    // Let's assume for now these are owned by UserProgress.
    // If they need to be independent entities with inverse relationships,
    // @Relationship would be needed.
    @Relationship(deleteRule: .cascade) // If UserProgress is deleted, associated LearningSessions are also deleted.
    var completedSessions: [LearningSession]? // Use optional if it can be empty initially or for flexibility

    init(currentLevel: Int = 1, totalWordsLearned: Int = 0, completedSessions: [LearningSession]? = []) {
        self.currentLevel = currentLevel
        self.totalWordsLearned = totalWordsLearned
        self.completedSessions = completedSessions
    }
}
