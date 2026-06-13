import Foundation
import SwiftData

// MARK: - Exercise
// Represents a single exercise in the library.
// Seed data is loaded from exercises.json on first launch.
// Users can also create custom exercises.
@Model
final class Exercise {
    // Unique identifier
    var id: UUID

    // Display name (e.g. "Bench Press", "Squat")
    var name: String

    // Primary muscle group targeted
    var muscleGroupRaw: String  // stored as raw string for SwiftData compatibility

    // Equipment category
    var categoryRaw: String

    // Training goal rep range
    var repRangeRaw: String

    // Whether this was user-created (vs. from seed data)
    var isCustom: Bool

    // When the exercise was created
    var createdAt: Date

    // Optional notes (e.g. form cues, alternative names)
    var notes: String

    // MARK: - Computed properties for enum access

    @Transient
    var muscleGroup: MuscleGroup {
        get { MuscleGroup(rawValue: muscleGroupRaw) ?? .fullBody }
        set { muscleGroupRaw = newValue.rawValue }
    }

    @Transient
    var category: ExerciseCategory {
        get { ExerciseCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    @Transient
    var repRange: RepRange {
        get { RepRange(rawValue: repRangeRaw) ?? .any }
        set { repRangeRaw = newValue.rawValue }
    }

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        name: String,
        muscleGroup: MuscleGroup,
        category: ExerciseCategory = .other,
        repRange: RepRange = .any,
        isCustom: Bool = false,
        createdAt: Date = Date(),
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.muscleGroupRaw = muscleGroup.rawValue
        self.categoryRaw = category.rawValue
        self.repRangeRaw = repRange.rawValue
        self.isCustom = isCustom
        self.createdAt = createdAt
        self.notes = notes
    }
}
