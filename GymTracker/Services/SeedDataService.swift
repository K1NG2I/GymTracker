import Foundation
import SwiftData

// MARK: - SeedDataService
// Handles loading seed data (exercises + templates) on first launch.
// Uses ModelActor for safe background access to SwiftData.
@ModelActor
actor SeedDataService {

    /// Check if seed data has already been loaded, and if not, load it.
    func ensureSeedData() {
        // Check if we already have exercises in the database
        let descriptor = FetchDescriptor<Exercise>()
        guard let count = try? modelContext.fetchCount(descriptor), count == 0 else {
            // Data already exists — nothing to do
            return
        }

        // Load exercises from the bundled JSON file
        loadExercisesFromBundle()
        loadBuiltInTemplates()

        // Mark seed as completed
        UserDefaults.standard.set(true, forKey: "seedDataLoaded")
        try? modelContext.save()
    }

    // MARK: - Load exercises from JSON

    private func loadExercisesFromBundle() {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let exercises = try? JSONDecoder().decode([SeedExercise].self, from: data) else {
            print("⚠️ SeedDataService: Could not load exercises.json")
            return
        }

        for seed in exercises {
            let exercise = Exercise(
                name: seed.name,
                muscleGroup: seed.muscleGroup,
                category: seed.category,
                repRange: seed.repRange,
                isCustom: false,
                notes: seed.notes
            )
            modelContext.insert(exercise)
        }

        print("✅ SeedDataService: Loaded \(exercises.count) exercises")
    }

    // MARK: - Load built-in templates

    private func loadBuiltInTemplates() {
        // Fetch all exercises (needed to reference them in templates)
        let descriptor = FetchDescriptor<Exercise>()
        guard let allExercises = try? modelContext.fetch(descriptor) else { return }

        // Helper to find an exercise by name
        func find(_ name: String) -> Exercise? {
            allExercises.first { $0.name.lowercased() == name.lowercased() }
        }

        // --- Full Body (3x/week — great for beginners) ---
        let fullBody = WorkoutTemplate(
            name: "Full Body",
            description: "A beginner-friendly full body workout. Perform 3 times per week with at least one rest day between sessions.",
            isBuiltIn: true,
            exercises: [
                TemplateExercise(order: 0, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 10, exercise: find("Barbell Squat")),
                TemplateExercise(order: 1, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 10, exercise: find("Bench Press")),
                TemplateExercise(order: 2, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 10, exercise: find("Barbell Row")),
                TemplateExercise(order: 3, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Dumbbell Shoulder Press")),
                TemplateExercise(order: 4, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 12, exercise: find("Dumbbell Curl")),
                TemplateExercise(order: 5, defaultSets: 2, defaultMinReps: 15, defaultMaxReps: 20, exercise: find("Plank")),
            ]
        )
        modelContext.insert(fullBody)

        // --- Upper/Lower (4x/week) ---
        // Upper A
        let upperA = WorkoutTemplate(
            name: "Upper A",
            description: "Upper body focus — horizontal push/pull.",
            isBuiltIn: true,
            exercises: [
                TemplateExercise(order: 0, defaultSets: 4, defaultMinReps: 6, defaultMaxReps: 8, exercise: find("Bench Press")),
                TemplateExercise(order: 1, defaultSets: 4, defaultMinReps: 6, defaultMaxReps: 8, exercise: find("Barbell Row")),
                TemplateExercise(order: 2, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Incline Dumbbell Press")),
                TemplateExercise(order: 3, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Face Pull")),
                TemplateExercise(order: 4, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 12, exercise: find("Dumbbell Curl")),
                TemplateExercise(order: 5, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 12, exercise: find("Tricep Pushdown")),
            ]
        )
        modelContext.insert(upperA)

        // Lower A
        let lowerA = WorkoutTemplate(
            name: "Lower A",
            description: "Lower body focus — squat & hinge pattern.",
            isBuiltIn: true,
            exercises: [
                TemplateExercise(order: 0, defaultSets: 4, defaultMinReps: 6, defaultMaxReps: 8, exercise: find("Barbell Squat")),
                TemplateExercise(order: 1, defaultSets: 4, defaultMinReps: 6, defaultMaxReps: 8, exercise: find("Romanian Deadlift")),
                TemplateExercise(order: 2, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Leg Press")),
                TemplateExercise(order: 3, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Leg Curl")),
                TemplateExercise(order: 4, defaultSets: 4, defaultMinReps: 12, defaultMaxReps: 15, exercise: find("Standing Calf Raise")),
            ]
        )
        modelContext.insert(lowerA)

        // Upper B
        let upperB = WorkoutTemplate(
            name: "Upper B",
            description: "Upper body focus — vertical push/pull.",
            isBuiltIn: true,
            exercises: [
                TemplateExercise(order: 0, defaultSets: 4, defaultMinReps: 6, defaultMaxReps: 8, exercise: find("Overhead Press")),
                TemplateExercise(order: 1, defaultSets: 4, defaultMinReps: 6, defaultMaxReps: 8, exercise: find("Pull-Up")),
                TemplateExercise(order: 2, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Dumbbell Bench Press")),
                TemplateExercise(order: 3, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Lateral Raise")),
                TemplateExercise(order: 4, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 12, exercise: find("Hammer Curl")),
                TemplateExercise(order: 5, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 12, exercise: find("Overhead Tricep Extension")),
            ]
        )
        modelContext.insert(upperB)

        // Lower B
        let lowerB = WorkoutTemplate(
            name: "Lower B",
            description: "Lower body focus — deadlift & unilateral work.",
            isBuiltIn: true,
            exercises: [
                TemplateExercise(order: 0, defaultSets: 4, defaultMinReps: 5, defaultMaxReps: 5, exercise: find("Deadlift")),
                TemplateExercise(order: 1, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Bulgarian Split Squat")),
                TemplateExercise(order: 2, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Leg Extension")),
                TemplateExercise(order: 3, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 12, exercise: find("Glute Bridge")),
                TemplateExercise(order: 4, defaultSets: 4, defaultMinReps: 12, defaultMaxReps: 15, exercise: find("Seated Calf Raise")),
            ]
        )
        modelContext.insert(lowerB)

        // --- Push Pull Legs ---
        let push = WorkoutTemplate(
            name: "Push",
            description: "Push day — chest, shoulders, triceps.",
            isBuiltIn: true,
            exercises: [
                TemplateExercise(order: 0, defaultSets: 4, defaultMinReps: 6, defaultMaxReps: 8, exercise: find("Bench Press")),
                TemplateExercise(order: 1, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Incline Dumbbell Press")),
                TemplateExercise(order: 2, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Dumbbell Shoulder Press")),
                TemplateExercise(order: 3, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Lateral Raise")),
                TemplateExercise(order: 4, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 12, exercise: find("Tricep Pushdown")),
                TemplateExercise(order: 5, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Dumbbell Flyes")),
            ]
        )
        modelContext.insert(push)

        let pull = WorkoutTemplate(
            name: "Pull",
            description: "Pull day — back, biceps, rear delts.",
            isBuiltIn: true,
            exercises: [
                TemplateExercise(order: 0, defaultSets: 4, defaultMinReps: 5, defaultMaxReps: 5, exercise: find("Deadlift")),
                TemplateExercise(order: 1, defaultSets: 4, defaultMinReps: 8, defaultMaxReps: 10, exercise: find("Barbell Row")),
                TemplateExercise(order: 2, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Pull-Up")),
                TemplateExercise(order: 3, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Face Pull")),
                TemplateExercise(order: 4, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 12, exercise: find("Barbell Curl")),
                TemplateExercise(order: 5, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Shrug")),
            ]
        )
        modelContext.insert(pull)

        let legs = WorkoutTemplate(
            name: "Legs",
            description: "Leg day — quads, hamstrings, glutes, calves.",
            isBuiltIn: true,
            exercises: [
                TemplateExercise(order: 0, defaultSets: 4, defaultMinReps: 6, defaultMaxReps: 8, exercise: find("Barbell Squat")),
                TemplateExercise(order: 1, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Romanian Deadlift")),
                TemplateExercise(order: 2, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Leg Press")),
                TemplateExercise(order: 3, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Leg Extension")),
                TemplateExercise(order: 4, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Leg Curl")),
                TemplateExercise(order: 5, defaultSets: 4, defaultMinReps: 12, defaultMaxReps: 15, exercise: find("Standing Calf Raise")),
            ]
        )
        modelContext.insert(legs)

        // --- Bro Split ---
        let broChest = WorkoutTemplate(
            name: "Chest Day",
            description: "Chest-focused day with some triceps work.",
            isBuiltIn: true,
            exercises: [
                TemplateExercise(order: 0, defaultSets: 4, defaultMinReps: 6, defaultMaxReps: 8, exercise: find("Bench Press")),
                TemplateExercise(order: 1, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Incline Dumbbell Press")),
                TemplateExercise(order: 2, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Dumbbell Flyes")),
                TemplateExercise(order: 3, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Cable Crossover")),
                TemplateExercise(order: 4, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 12, exercise: find("Tricep Pushdown")),
                TemplateExercise(order: 5, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Push-Up")),
            ]
        )
        modelContext.insert(broChest)

        let broBack = WorkoutTemplate(
            name: "Back Day",
            description: "Back thickness and width.",
            isBuiltIn: true,
            exercises: [
                TemplateExercise(order: 0, defaultSets: 4, defaultMinReps: 6, defaultMaxReps: 8, exercise: find("Deadlift")),
                TemplateExercise(order: 1, defaultSets: 4, defaultMinReps: 8, defaultMaxReps: 10, exercise: find("Barbell Row")),
                TemplateExercise(order: 2, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Pull-Up")),
                TemplateExercise(order: 3, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Seated Cable Row")),
                TemplateExercise(order: 4, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Face Pull")),
                TemplateExercise(order: 5, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 12, exercise: find("Dumbbell Row")),
            ]
        )
        modelContext.insert(broBack)

        let broShoulders = WorkoutTemplate(
            name: "Shoulder Day",
            description: "Overhead pressing and delt isolation.",
            isBuiltIn: true,
            exercises: [
                TemplateExercise(order: 0, defaultSets: 4, defaultMinReps: 6, defaultMaxReps: 8, exercise: find("Overhead Press")),
                TemplateExercise(order: 1, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Dumbbell Shoulder Press")),
                TemplateExercise(order: 2, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Lateral Raise")),
                TemplateExercise(order: 3, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Front Raise")),
                TemplateExercise(order: 4, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Rear Delt Fly")),
                TemplateExercise(order: 5, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 12, exercise: find("Shrug")),
            ]
        )
        modelContext.insert(broShoulders)

        let broArms = WorkoutTemplate(
            name: "Arm Day",
            description: "Biceps, triceps, and forearms.",
            isBuiltIn: true,
            exercises: [
                TemplateExercise(order: 0, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Barbell Curl")),
                TemplateExercise(order: 1, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Skull Crusher")),
                TemplateExercise(order: 2, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 12, exercise: find("Hammer Curl")),
                TemplateExercise(order: 3, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 12, exercise: find("Tricep Pushdown")),
                TemplateExercise(order: 4, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 12, exercise: find("Preacher Curl")),
                TemplateExercise(order: 5, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 12, exercise: find("Overhead Tricep Extension")),
            ]
        )
        modelContext.insert(broArms)

        let broLegs = WorkoutTemplate(
            name: "Leg Day",
            description: "Full leg development — quads, hamstrings, glutes, calves.",
            isBuiltIn: true,
            exercises: [
                TemplateExercise(order: 0, defaultSets: 4, defaultMinReps: 6, defaultMaxReps: 8, exercise: find("Barbell Squat")),
                TemplateExercise(order: 1, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Leg Press")),
                TemplateExercise(order: 2, defaultSets: 3, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Romanian Deadlift")),
                TemplateExercise(order: 3, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Leg Extension")),
                TemplateExercise(order: 4, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Leg Curl")),
                TemplateExercise(order: 5, defaultSets: 4, defaultMinReps: 12, defaultMaxReps: 15, exercise: find("Standing Calf Raise")),
            ]
        )
        modelContext.insert(broLegs)

        // --- Hypertrophy Program ---
        let hypertrophyUpper = WorkoutTemplate(
            name: "Hypertrophy Upper",
            description: "Upper body hypertrophy focus — higher volume, 8-12 rep range, shorter rest.",
            isBuiltIn: true,
            exercises: [
                TemplateExercise(order: 0, defaultSets: 4, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Bench Press")),
                TemplateExercise(order: 1, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Incline Dumbbell Press")),
                TemplateExercise(order: 2, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 12, exercise: find("Dumbbell Row")),
                TemplateExercise(order: 3, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Lateral Raise")),
                TemplateExercise(order: 4, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Face Pull")),
                TemplateExercise(order: 5, defaultSets: 3, defaultMinReps: 12, defaultMaxReps: 15, exercise: find("Dumbbell Curl")),
                TemplateExercise(order: 6, defaultSets: 3, defaultMinReps: 12, defaultMaxReps: 15, exercise: find("Tricep Pushdown")),
            ]
        )
        modelContext.insert(hypertrophyUpper)

        let hypertrophyLower = WorkoutTemplate(
            name: "Hypertrophy Lower",
            description: "Lower body hypertrophy focus — higher volume, 8-15 rep range.",
            isBuiltIn: true,
            exercises: [
                TemplateExercise(order: 0, defaultSets: 4, defaultMinReps: 8, defaultMaxReps: 12, exercise: find("Barbell Squat")),
                TemplateExercise(order: 1, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Romanian Deadlift")),
                TemplateExercise(order: 2, defaultSets: 3, defaultMinReps: 12, defaultMaxReps: 15, exercise: find("Leg Press")),
                TemplateExercise(order: 3, defaultSets: 3, defaultMinReps: 12, defaultMaxReps: 15, exercise: find("Leg Extension")),
                TemplateExercise(order: 4, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Leg Curl")),
                TemplateExercise(order: 5, defaultSets: 4, defaultMinReps: 15, defaultMaxReps: 20, exercise: find("Standing Calf Raise")),
                TemplateExercise(order: 6, defaultSets: 3, defaultMinReps: 10, defaultMaxReps: 15, exercise: find("Bulgarian Split Squat")),
            ]
        )
        modelContext.insert(hypertrophyLower)

        print("✅ SeedDataService: Loaded \(12) built-in templates")
    }
}

// MARK: - Codable struct matching exercises.json
private struct SeedExercise: Codable {
    let name: String
    let muscleGroup: MuscleGroup
    let category: ExerciseCategory
    let repRange: RepRange
    let notes: String
}
