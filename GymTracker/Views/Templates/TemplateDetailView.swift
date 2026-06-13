import SwiftUI
import SwiftData

// MARK: - TemplateDetailView
// Shows the exercises in a template with default sets/reps.
// Users can start a workout from here, duplicate, or edit the template.
struct TemplateDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var template: WorkoutTemplate
    @State private var showingStartWorkout = false
    @State private var workoutManager = WorkoutManager()

    init(template: WorkoutTemplate) {
        self._template = State(initialValue: template)
    }

    var body: some View {
        List {
            // Header info
            Section {
                if !template.templateDescription.isEmpty {
                    Text(template.templateDescription)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("\(template.exercises.count) exercises", systemImage: "number")
                    Spacer()
                    if template.isBuiltIn {
                        Text("Built-in")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }

            // Exercise list
            Section("Exercises") {
                let sortedExercises = template.exercises.sorted { $0.order < $1.order }

                if sortedExercises.isEmpty {
                    Text("No exercises in this template yet.")
                        .foregroundStyle(.secondary)
                }

                ForEach(sortedExercises, id: \.id) { templateExercise in
                    HStack {
                        // Exercise info
                        VStack(alignment: .leading, spacing: 2) {
                            if let exercise = templateExercise.exercise {
                                Text(exercise.name)
                                    .font(.body)

                                HStack(spacing: 4) {
                                    Text("\(templateExercise.defaultSets) sets")
                                    if let minReps = templateExercise.defaultMinReps,
                                       let maxReps = templateExercise.defaultMaxReps {
                                        Text("· \(minReps)-\(maxReps) reps")
                                    }
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            } else {
                                Text("Unknown exercise")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        if let exercise = templateExercise.exercise {
                            MuscleGroupIcon(muscleGroup: exercise.muscleGroup, size: 18)
                        }
                    }
                }
                .onMove { from, to in
                    // Update order when moved
                    var sorted = template.exercises.sorted { $0.order < $1.order }
                    sorted.move(fromOffsets: from, toOffset: to)
                    for (index, te) in sorted.enumerated() {
                        te.order = index
                    }
                }
            }

            // Actions
            Section {
                Button {
                    workoutManager.startWorkout(from: template, in: modelContext)
                    showingStartWorkout = true
                } label: {
                    Label("Start Workout", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                }
                .listRowBackground(Color.appAccent)
                .disabled(template.exercises.isEmpty)

                if !template.isBuiltIn {
                    Button(role: .destructive) {
                        template.exercises.forEach { modelContext.delete($0) }
                        modelContext.delete(template)
                    } label: {
                        Label("Delete Template", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .navigationTitle(template.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                EditButton()
            }
        }
        .fullScreenCover(isPresented: $showingStartWorkout) {
            ActiveWorkoutView(manager: workoutManager)
        }
    }
}
