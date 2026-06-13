import Foundation
import SwiftData
import Observation

// MARK: - WorkoutManager
// Observable class that manages the state of the active workout.
// This is the brain of the app during an active session.
// It handles: starting a workout, logging sets, managing current exercise,
// saving progress, and finishing/cancelling.
@Observable
final class WorkoutManager {

    // The active workout session. nil when no workout is in progress.
    var currentSession: WorkoutSession?

    // The currently selected exercise within the workout.
    // Used by ExerciseLogView to know which exercise to show.
    var currentExercise: Exercise?

    // All exercises in the current workout (in order).
    // Populated from the template, or added on the fly in free mode.
    var exercises: [Exercise] = []

    // The index of the current exercise in the exercises array.
    var currentExerciseIndex: Int = 0

    // Whether a workout is currently active.
    var isWorkoutActive: Bool {
        currentSession != nil
    }

    // The model context — must be set externally by the view layer.
    var modelContext: ModelContext?

    // MARK: - Starting a workout

    /// Start a new workout from a template.
    func startWorkout(from template: WorkoutTemplate, in context: ModelContext) {
        modelContext = context

        let session = WorkoutSession(template: template)
        context.insert(session)
        currentSession = session

        // Build the ordered exercise list from the template
        let sortedExercises = template.exercises
            .sorted { $0.order < $1.order }
            .compactMap { $0.exercise }
        exercises = sortedExercises
        currentExerciseIndex = 0
        currentExercise = exercises.first
    }

    /// Start a "free" workout with no template — user adds exercises as they go.
    func startFreeWorkout(in context: ModelContext) {
        modelContext = context

        let session = WorkoutSession()
        context.insert(session)
        currentSession = session

        exercises = []
        currentExerciseIndex = 0
        currentExercise = nil
    }

    // MARK: - Adding exercises (free workout)

    /// Add an exercise to the current workout on the fly.
    func addExercise(_ exercise: Exercise) {
        exercises.append(exercise)
        if currentExercise == nil {
            currentExercise = exercise
            currentExerciseIndex = 0
        }
    }

    /// Move to the next exercise in the workout.
    func moveToNextExercise() {
        guard currentExerciseIndex + 1 < exercises.count else { return }
        currentExerciseIndex += 1
        currentExercise = exercises[currentExerciseIndex]
    }

    /// Move to the previous exercise.
    func moveToPreviousExercise() {
        guard currentExerciseIndex > 0 else { return }
        currentExerciseIndex -= 1
        currentExercise = exercises[currentExerciseIndex]
    }

    // MARK: - Logging sets

    /// Log a completed set for the current exercise.
    func logSet(reps: Int, weight: Double, isWarmup: Bool = false) {
        guard let session = currentSession,
              let exercise = currentExercise,
              let context = modelContext else { return }

        let setIndex = session.sets.filter { $0.exercise?.id == exercise.id }.count + 1
        let set = ExerciseSet(
            setIndex: setIndex,
            reps: reps,
            weight: weight,
            completedAt: Date(),
            isWarmup: isWarmup,
            exercise: exercise
        )
        set.session = session
        context.insert(set)
        session.sets.append(set)

        // Save automatically so progress isn't lost if the app crashes
        try? context.save()
    }

    /// Delete a previously logged set (swipe-to-delete).
    func deleteSet(_ set: ExerciseSet) {
        guard let context = modelContext else { return }
        context.delete(set)
        currentSession?.sets.removeAll { $0.id == set.id }
        try? context.save()
    }

    /// Update a previously logged set (e.g. edit reps or weight).
    func updateSet(_ set: ExerciseSet, reps: Int, weight: Double) {
        set.reps = reps
        set.weight = weight
        try? modelContext?.save()
    }

    // MARK: - Finishing & cancelling

    /// Complete the workout. Sets endedAt and marks as completed.
    func finishWorkout(notes: String = "") {
        guard let session = currentSession else { return }
        session.endedAt = Date()
        session.notes = notes
        session.isCompleted = true
        try? modelContext?.save()

        // Reset state
        currentSession = nil
        currentExercise = nil
        exercises = []
        modelContext = nil
    }

    /// Cancel the workout without saving (removes all data).
    func cancelWorkout() {
        guard let session = currentSession,
              let context = modelContext else { return }

        // Delete all sets first
        for set in session.sets {
            context.delete(set)
        }
        // Then delete the session
        context.delete(session)
        try? context.save()

        // Reset state
        currentSession = nil
        currentExercise = nil
        exercises = []
        modelContext = nil
    }

    // MARK: - Helpers

    /// Returns all sets for a given exercise in the current session.
    func sets(for exercise: Exercise) -> [ExerciseSet] {
        guard let session = currentSession else { return [] }
        return session.sets
            .filter { $0.exercise?.id == exercise.id }
            .sorted { $0.setIndex < $1.setIndex }
    }
}
