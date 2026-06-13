import Foundation
import SwiftData

// MARK: - WorkoutTemplate
// A reusable workout routine (e.g. "Push Day", "Full Body")
// Contains an ordered list of exercises via TemplateExercise.
// Built-in templates are seeded on first launch; users can create their own.
@Model
final class WorkoutTemplate {
    var id: UUID
    var name: String
    var templateDescription: String  // shown when picking a template
    var isBuiltIn: Bool              // true for seeded templates
    var createdAt: Date

    // Ordered list of exercises in this template
    @Relationship(deleteRule: .cascade) var exercises: [TemplateExercise]

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        isBuiltIn: Bool = false,
        createdAt: Date = Date(),
        exercises: [TemplateExercise] = []
    ) {
        self.id = id
        self.name = name
        self.templateDescription = description
        self.isBuiltIn = isBuiltIn
        self.createdAt = createdAt
        self.exercises = exercises
    }
}

// MARK: - TemplateExercise
// Links an Exercise to a WorkoutTemplate with ordering and default set/rep config
@Model
final class TemplateExercise {
    var id: UUID
    var order: Int          // position in the template (0-based)
    var defaultSets: Int    // default number of sets (e.g. 3 or 4)
    var defaultMinReps: Int? // lower bound of target rep range
    var defaultMaxReps: Int? // upper bound of target rep range

    // Relationship back to the template
    var template: WorkoutTemplate?

    // The exercise this template entry refers to
    var exercise: Exercise?

    init(
        id: UUID = UUID(),
        order: Int,
        defaultSets: Int = 3,
        defaultMinReps: Int? = nil,
        defaultMaxReps: Int? = nil,
        exercise: Exercise? = nil
    ) {
        self.id = id
        self.order = order
        self.defaultSets = defaultSets
        self.defaultMinReps = defaultMinReps
        self.defaultMaxReps = defaultMaxReps
        self.exercise = exercise
    }
}
