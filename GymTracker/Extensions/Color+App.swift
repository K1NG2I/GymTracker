import SwiftUI

// MARK: - App Color Palette
// Consistent colors used throughout the app.
extension Color {

    /// Primary accent color — used for buttons and highlights
    static let appAccent = Color.orange

    /// Background color for cards and list rows
    static let cardBackground = Color(.systemGray6)

    /// Color for completed sets
    static let setCompleted = Color.green

    /// Color for warmup sets
    static let setWarmup = Color.yellow

    /// Color for rest timer display
    static let restTimer = Color.blue

    /// Muscle group colors — used in library grid and charts
    static func muscleGroupColor(_ group: MuscleGroup) -> Color {
        switch group {
        case .chest:     return .red
        case .back:      return .blue
        case .shoulders: return .orange
        case .legs:      return .purple
        case .biceps:    return .green
        case .triceps:   return .teal
        case .core:      return .yellow
        case .cardio:    return .pink
        case .fullBody:  return .gray
        }
    }
}
