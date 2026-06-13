import Foundation

// MARK: - Muscle Groups
// Each exercise targets one primary muscle group
enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case legs = "Legs"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case core = "Core"
    case cardio = "Cardio"
    case fullBody = "Full Body"

    var id: String { rawValue }

    // SF Symbol name for each muscle group — used in the UI
    var iconName: String {
        switch self {
        case .chest:     return "figure.strengthtraining.traditional"
        case .back:      return "figure.rower"
        case .shoulders: return "figure.strengthtraining.functional"
        case .legs:      return "figure.walk"
        case .biceps:    return "arm.bicep"
        case .triceps:   return "arm.bicep" // close enough
        case .core:      return "figure.core.training"
        case .cardio:    return "heart.circle"
        case .fullBody:  return "figure.highintensity.intervaltraining"
        }
    }
}

// MARK: - Exercise Category
// What kind of equipment the exercise uses
enum ExerciseCategory: String, Codable, CaseIterable, Identifiable {
    case barbell    = "Barbell"
    case dumbbell   = "Dumbbell"
    case cable      = "Cable"
    case machine    = "Machine"
    case bodyweight = "Bodyweight"
    case banded     = "Banded"
    case kettlebell = "Kettlebell"
    case other      = "Other"

    var id: String { rawValue }
}

// MARK: - Rep Range
// Tags each exercise with its ideal rep range goal
// This lets users filter exercises based on their training goal
enum RepRange: String, Codable, CaseIterable, Identifiable {
    case strength    = "Strength"
    case hypertrophy = "Hypertrophy"
    case endurance   = "Endurance"
    case any         = "Any"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .strength:    return "1-5 reps"
        case .hypertrophy: return "6-12 reps"
        case .endurance:   return "15+ reps"
        case .any:         return "Any range"
        }
    }

    var minReps: Int? {
        switch self {
        case .strength:    return 1
        case .hypertrophy: return 6
        case .endurance:   return 15
        case .any:         return nil
        }
    }

    var maxReps: Int? {
        switch self {
        case .strength:    return 5
        case .hypertrophy: return 12
        case .endurance:   return nil
        case .any:         return nil
        }
    }
}
