import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - WorkoutLiveActivity
// A Live Activity that shows on the Dynamic Island / Lock Screen
// during an active workout, showing current exercise and progress.
struct WorkoutActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic content that updates during the workout
        var currentExerciseName: String
        var setsCompleted: Int
        var totalSets: Int
        var elapsedMinutes: Int
    }

    // Static content set when the activity starts
    var workoutName: String
}

struct WorkoutLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            // Lock screen / banner UI
            WorkoutLiveActivityView(context: context)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Dynamic Island
                DynamicIslandExpandedContent(.leading) {
                    Label(context.attributes.workoutName, systemImage: "figure.run")
                }
                DynamicIslandExpandedContent(.trailing) {
                    Text("\(context.state.setsCompleted)/\(context.state.totalSets)")
                }
                DynamicIslandExpandedContent(.center) {
                    Text(context.state.currentExerciseName)
                        .font(.headline)
                }
                DynamicIslandExpandedContent(.bottom) {
                    HStack {
                        Text("\(context.state.elapsedMinutes)m")
                        ProgressView(value: Double(context.state.setsCompleted),
                                     total: Double(max(context.state.totalSets, 1)))
                    }
                }
            } compactLeading: {
                Label("\(context.state.setsCompleted)", systemImage: "dumbbell.fill")
            } compactTrailing: {
                Text("\(context.state.elapsedMinutes)m")
            } minimal: {
                Image(systemName: "dumbbell.fill")
            }
        }
    }
}

// MARK: - Live Activity View (Lock Screen)
struct WorkoutLiveActivityView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(context.attributes.workoutName)
                    .font(.headline)

                Text(context.state.currentExerciseName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ProgressView(value: Double(context.state.setsCompleted),
                             total: Double(max(context.state.totalSets, 1)))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(context.state.elapsedMinutes)m")
                    .font(.title2.monospacedDigit())

                Text("\(context.state.setsCompleted)/\(context.state.totalSets) sets")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .activityBackgroundTint(Color.orange.opacity(0.2))
        .activitySystemActionForegroundColor(.primary)
    }
}
