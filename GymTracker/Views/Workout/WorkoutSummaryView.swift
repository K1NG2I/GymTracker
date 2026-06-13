import SwiftUI
import SwiftData

// MARK: - WorkoutSummaryView
// Shown after a workout is completed.
// Provides a recap of what was accomplished and options to share or view in history.
struct WorkoutSummaryView: View {
    let session: WorkoutSession

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.green)

                        Text("Workout Complete!")
                            .font(.title.bold())

                        if let templateName = session.template?.name {
                            Text(templateName)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 20)

                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        statCard(title: "Duration", value: "\(session.durationMinutes)", unit: "min")
                        statCard(title: "Exercises", value: "\(session.uniqueExerciseCount)", unit: "")
                        statCard(title: "Sets", value: "\(session.totalSets)", unit: "")
                        statCard(title: "Volume", value: "\(Int(session.totalVolume))", unit: "kg")
                    }
                    .padding(.horizontal)

                    // Per-exercise breakdown
                    let exercises = Set(session.sets.compactMap { $0.exercise })
                    if !exercises.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Exercise Breakdown")
                                .font(.headline)

                            ForEach(Array(exercises).sorted { $0.name < $1.name }) { exercise in
                                let exerciseSets = session.sets
                                    .filter { $0.exercise?.id == exercise.id }
                                    .sorted { $0.setIndex < $1.setIndex }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.name)
                                        .font(.subheadline.bold())

                                    ForEach(exerciseSets) { set in
                                        HStack {
                                            Text("Set \(set.setIndex)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)

                                            Text("\(set.reps) reps × \(set.weight, specifier: "%.1f") kg")
                                                .font(.caption.monospacedDigit())

                                            if set.isWarmup {
                                                Text("(warmup)")
                                                    .font(.caption2)
                                                    .foregroundStyle(.orange)
                                            }

                                            Spacer()
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Notes
                    if !session.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(session.notes)
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                    }

                    // Done button
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appAccent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Stat card

    private func statCard(title: String, value: String, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title.bold())

            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
