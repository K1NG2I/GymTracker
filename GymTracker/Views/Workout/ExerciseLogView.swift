import SwiftUI

// MARK: - ExerciseLogView
// The screen where users log individual sets for the current exercise.
// Shows previously completed sets above, and input controls for the next set below.
struct ExerciseLogView: View {
    let exercise: Exercise
    let manager: WorkoutManager

    // Input state for the next set
    @State private var reps: Int = 10
    @State private var weight: Double = 20.0
    @State private var isWarmup: Bool = false
    @State private var rpe: Double? = nil

    @State private var showingRestTimer = false

    var body: some View {
        VStack(spacing: 0) {
            // Exercise info header
            exerciseInfoHeader

            // Completed sets list
            completedSetsList

            // Divider
            Divider()
                .padding(.horizontal)

            // New set input
            newSetInput
        }
    }

    // MARK: - Exercise info

    private var exerciseInfoHeader: some View {
        HStack {
            MuscleGroupIcon(muscleGroup: exercise.muscleGroup, size: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.title3.bold())

                Text("\(exercise.muscleGroup.rawValue) · \(exercise.category.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Target rep range badge
            if exercise.repRange != .any {
                Text(exercise.repRange.description)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(tagColor.opacity(0.2))
                    .foregroundStyle(tagColor)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color.cardBackground)
    }

    private var tagColor: Color {
        switch exercise.repRange {
        case .strength:    return .red
        case .hypertrophy: return .green
        case .endurance:   return .blue
        case .any:         return .gray
        }
    }

    // MARK: - Completed sets list

    private var completedSetsList: some View {
        let completedSets = manager.sets(for: exercise)

        return Group {
            if completedSets.isEmpty {
                EmptyStateView(
                    icon: "tray",
                    title: "No sets yet",
                    message: "Log your first set below"
                )
                .frame(maxHeight: .infinity)
            } else {
                List {
                    Section("Completed Sets") {
                        ForEach(completedSets) { set in
                            SetRow(set: set) {
                                manager.deleteSet(set)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    // MARK: - New set input

    private var newSetInput: some View {
        VStack(spacing: 12) {
            // Input fields
            HStack(spacing: 24) {
                // Warmup toggle
                Toggle(isOn: $isWarmup) {
                    Text("Warmup")
                        .font(.caption)
                }
                .toggleStyle(.button)
                .tint(.orange)

                Spacer()

                // Weight input
                HStack(spacing: 4) {
                    TextField("Weight", value: $weight, format: .number.precision(.fractionLength(1)))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                        .multilineTextAlignment(.center)

                    Text("kg")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Reps input
                HStack(spacing: 4) {
                    TextField("Reps", value: $reps, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        .multilineTextAlignment(.center)

                    Text("reps")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Quick weight selectors (common plate math)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach([5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 40.0, 50.0, 60.0, 80.0, 100.0], id: \.self) { val in
                        Button("\(Int(val))") {
                            weight = val
                        }
                        .buttonStyle(.bordered)
                        .tint(weight == val ? .appAccent : .secondary)
                        .font(.caption)
                    }
                }
            }

            // Log set button
            Button {
                manager.logSet(reps: reps, weight: weight, isWarmup: isWarmup)
                // Open rest timer after logging
                showingRestTimer = true
                // Reset to defaults for next set
                isWarmup = false
            } label: {
                Label("Log Set", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appAccent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Navigation between exercises
            HStack {
                // Previous exercise
                if manager.currentExerciseIndex > 0 {
                    Button {
                        manager.moveToPreviousExercise()
                    } label: {
                        Label("Previous", systemImage: "chevron.left")
                            .font(.subheadline)
                    }
                    .tint(.secondary)
                }

                Spacer()

                // Next exercise
                if manager.currentExerciseIndex < manager.exercises.count - 1 {
                    Button {
                        manager.moveToNextExercise()
                    } label: {
                        Label("Next", systemImage: "chevron.right")
                            .font(.subheadline)
                            .labelStyle(.trailingIcon)
                    }
                    .tint(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingRestTimer) {
            RestTimerView()
                .presentationDetents([.height(400)])
        }
    }
}

// MARK: - Label style for trailing icon
extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: TrailingIconLabelStyle { TrailingIconLabelStyle() }
}

struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}
