import SwiftUI

// MARK: - SetRow
// Displays a single logged set with its set number, reps, weight, and status.
// Used in ExerciseLogView to show the history of completed sets.
struct SetRow: View {
    let set: ExerciseSet
    var onDelete: (() -> Void)?

    var body: some View {
        HStack {
            // Set number badge
            ZStack {
                Circle()
                    .fill(set.isWarmup ? Color.setWarmup : Color.setCompleted)
                    .frame(width: 32, height: 32)

                Text("\(set.setIndex)")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("\(set.reps) reps")
                        .font(.body.monospacedDigit())

                    Text("×")
                        .foregroundStyle(.secondary)

                    Text("\(set.weight, specifier: "%.1f") kg")
                        .font(.body.monospacedDigit())
                }

                if set.isWarmup {
                    Text("Warmup")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            Spacer()

            // RPE badge if set
            if let rpe = set.rpe {
                Text("RPE \(rpe, specifier: "%.1f")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            }

            // Completed time
            if let completedAt = set.completedAt {
                Text(completedAt.timeString)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing) {
            if let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let set = ExerciseSet(setIndex: 1, reps: 10, weight: 60.0, completedAt: Date())
    List {
        SetRow(set: set)
    }
}
