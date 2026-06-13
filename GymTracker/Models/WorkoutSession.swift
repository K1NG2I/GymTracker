import Foundation
import SwiftData

// MARK: - WorkoutSession
// A single workout session from start to finish.
// Tracks which template was used (if any), when it happened, and notes.
@Model
final class WorkoutSession {
    var id: UUID
    var startedAt: Date
    var endedAt: Date?
    var notes: String
    var isCompleted: Bool  // true when the user taps "Finish"

    // Optional link to the template this session was based on
    var template: WorkoutTemplate?

    // All sets logged during this session
    @Relationship(deleteRule: .cascade) var sets: [ExerciseSet]

    init(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        template: WorkoutTemplate? = nil,
        notes: String = "",
        isCompleted: Bool = false,
        sets: [ExerciseSet] = []
    ) {
        self.id = id
        self.startedAt = startedAt
        self.template = template
        self.notes = notes
        self.isCompleted = isCompleted
        self.sets = sets
    }

    // Computed: duration of the workout in minutes
    @Transient
    var durationMinutes: Int {
        guard let endedAt else {
            return Int(Date().timeIntervalSince(startedAt) / 60)
        }
        return Int(endedAt.timeIntervalSince(startedAt) / 60)
    }

    // Computed: total volume (sum of weight * reps across all non-warmup sets)
    @Transient
    var totalVolume: Double {
        sets.filter { !$0.isWarmup }
            .reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }

    // Computed: unique exercises performed
    @Transient
    var uniqueExerciseCount: Int {
        Set(sets.compactMap { $0.exercise?.id }).count
    }

    // Computed: total sets performed
    @Transient
    var totalSets: Int {
        sets.count
    }
}

// MARK: - ExerciseSet
// A single set of an exercise: weight, reps, and metadata.
@Model
final class ExerciseSet {
    var id: UUID
    var setIndex: Int       // which set number this is (1, 2, 3, ...)
    var reps: Int
    var weight: Double      // in kg (convert to lbs for display if needed)
    var rpe: Double?        // Rate of Perceived Exertion (1-10), optional
    var completedAt: Date?
    var isWarmup: Bool      // warmup sets are tracked but excluded from volume/PRs

    // Relationships
    var session: WorkoutSession?
    var exercise: Exercise?

    init(
        id: UUID = UUID(),
        setIndex: Int,
        reps: Int = 0,
        weight: Double = 0,
        rpe: Double? = nil,
        completedAt: Date? = nil,
        isWarmup: Bool = false,
        exercise: Exercise? = nil
    ) {
        self.id = id
        self.setIndex = setIndex
        self.reps = reps
        self.weight = weight
        self.rpe = rpe
        self.completedAt = completedAt
        self.isWarmup = isWarmup
        self.exercise = exercise
    }
}
