import SwiftUI

// MARK: - EmptyStateView
// A reusable placeholder view for empty lists.
// Shows an icon, title, and optional message.
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: icon,
            description: Text(message)
        )
    }
}

// MARK: - Convenience initializers
extension EmptyStateView {

    static func noExercises() -> EmptyStateView {
        EmptyStateView(
            icon: "dumbbell",
            title: "No Exercises Yet",
            message: "Tap + to add your first exercise, or restart the app to load the built-in library."
        )
    }

    static func noWorkouts() -> EmptyStateView {
        EmptyStateView(
            icon: "figure.run",
            title: "No Workouts Yet",
            message: "Start a new workout to begin tracking your progress!"
        )
    }

    static func noSets() -> EmptyStateView {
        EmptyStateView(
            icon: "tray",
            title: "No Sets Logged",
            message: "Complete a set to see it here."
        )
    }

    static func noTemplates() -> EmptyStateView {
        EmptyStateView(
            icon: "list.bullet.clipboard",
            title: "No Templates",
            message: "Built-in templates are loaded on first launch. You can also create your own!"
        )
    }
}

#Preview {
    EmptyStateView.noWorkouts()
}
