import SwiftUI
import SwiftData

// MARK: - SessionDetailView
// Full breakdown of a past workout session.
// Shows exercises performed, sets logged, and totals.
struct SessionDetailView: View {
    @State private var session: WorkoutSession

    init(session: WorkoutSession) {
        self._session = State(initialValue: session)
    }

    var body: some View {
        List {
            // Summary section
            Section("Summary") {
                HStack {
                    Label("Duration", systemImage: "clock")
                    Spacer()
                    Text("\(session.durationMinutes) min")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Total Sets", systemImage: "number")
                    Spacer()
                    Text("\(session.totalSets)")
                        .foregroundStyle(.secondary)
                }

                if session.totalVolume > 0 {
                    HStack {
                        Label("Total Volume", systemImage: "scalemass")
                        Spacer()
                        Text("\(Int(session.totalVolume)) kg")
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Label("Exercises", systemImage: "figure.run")
                    Spacer()
                    Text("\(session.uniqueExerciseCount)")
                        .foregroundStyle(.secondary)
                }

                if let template = session.template {
                    HStack {
                        Label("Template", systemImage: "list.bullet.clipboard")
                        Spacer()
                        Text(template.name)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Label("Date", systemImage: "calendar")
                    Spacer()
                    Text(session.startedAt.workoutDateString)
                        .foregroundStyle(.secondary)
                }
            }

            // Exercises performed
            let exerciseGroups = Dictionary(grouping: session.sets.sorted { $0.setIndex < $1.setIndex }) {
                $0.exercise?.name ?? "Unknown"
            }

            ForEach(exerciseGroups.keys.sorted(), id: \.self) { exerciseName in
                Section(exerciseName) {
                    let sets = exerciseGroups[exerciseName]!
                    ForEach(sets) { set in
                        HStack {
                            Text("Set \(set.setIndex)")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Spacer()

                            Text("\(set.reps) reps × \(set.weight, specifier: "%.1f") kg")
                                .font(.body.monospacedDigit())

                            if set.isWarmup {
                                Text("warmup")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.orange.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }

            // Notes
            if !session.notes.isEmpty {
                Section("Notes") {
                    Text(session.notes)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(session.template?.name ?? "Free Session")
        .navigationBarTitleDisplayMode(.large)
    }
}
