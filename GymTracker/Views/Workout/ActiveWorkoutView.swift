import SwiftUI
import SwiftData

// MARK: - ActiveWorkoutView
// The main screen shown during an active workout.
// Shows the current exercise, allows logging sets, navigating between exercises.
struct ActiveWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var manager: WorkoutManager

    init(manager: WorkoutManager) {
        self._manager = State(initialValue: manager)
    }

    @State private var showingFinishSheet = false
    @State private var showingRestTimer = false
    @State private var showingAddExercise = false
    @State private var showingCancelAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header: workout info and duration
                workoutHeader

                // Exercise navigation
                if manager.exercises.isEmpty {
                    // Free workout with no exercises yet
                    emptyExerciseState
                } else {
                    exerciseContent
                }
            }
            .navigationTitle(manager.currentSession?.template?.name ?? "Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarButtons
            }
            .sheet(isPresented: $showingFinishSheet) {
                finishWorkoutSheet
            }
            .sheet(isPresented: $showingRestTimer) {
                RestTimerView()
                    .presentationDetents([.height(400)])
            }
            .sheet(isPresented: $showingAddExercise) {
                addExerciseSheet
            }
            .alert("Cancel Workout?", isPresented: $showingCancelAlert) {
                Button("Keep Going", role: .cancel) {}
                Button("Delete Workout", role: .destructive) {
                    manager.cancelWorkout()
                    dismiss()
                }
            } message: {
                Text("All progress in this session will be lost.")
            }
        }
    }

    // MARK: - Header

    private var workoutHeader: some View {
        HStack {
            // Duration
            Label(manager.currentSession?.durationMinutes ?? 0 > 0
                  ? "\(manager.currentSession?.durationMinutes ?? 0)m"
                  : "0m",
                  systemImage: "clock")

            Spacer()

            // Sets logged
            Label("\(manager.currentSession?.totalSets ?? 0) sets", systemImage: "number")

            Spacer()

            // Volume
            if let volume = manager.currentSession?.totalVolume, volume > 0 {
                Label("\(Int(volume)) kg", systemImage: "scalemass")
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.cardBackground)
    }

    // MARK: - Empty state (free workout)

    private var emptyExerciseState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "plus.circle")
                .font(.system(size: 48))
                .foregroundStyle(Color.appAccent)

            Text("Add your first exercise")
                .font(.headline)

            Text("Tap the + button to add exercises to this session")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingAddExercise = true
            } label: {
                Label("Add Exercise", systemImage: "plus")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.appAccent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()
        }
    }

    // MARK: - Exercise content

    private var exerciseContent: some View {
        VStack(spacing: 0) {
            // Exercise selector tabs
            exerciseTabBar

            // Current exercise logging
            if let currentExercise = manager.currentExercise {
                ExerciseLogView(
                    exercise: currentExercise,
                    manager: manager
                )
            }
        }
    }

    private var exerciseTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(manager.exercises.enumerated()), id: \.element.id) { index, exercise in
                    Button {
                        manager.currentExerciseIndex = index
                        manager.currentExercise = exercise
                    } label: {
                        VStack(spacing: 2) {
                            Text(exercise.name)
                                .font(.caption)
                                .fontWeight(index == manager.currentExerciseIndex ? .bold : .regular)
                                .lineLimit(1)

                            // Sets indicator
                            let count = manager.sets(for: exercise).count
                            Text("\(count) sets")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(index == manager.currentExerciseIndex
                                    ? Color.appAccent.opacity(0.15)
                                    : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarButtons: some ToolbarContent {
        // Cancel button (left)
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                showingCancelAlert = true
            }
            .foregroundStyle(.red)
        }

        // Rest timer toggle
        ToolbarItem(placement: .automatic) {
            Button {
                showingRestTimer.toggle()
            } label: {
                Label("Rest Timer", systemImage: "timer")
            }
        }

        // Add exercise (free workouts)
        ToolbarItem(placement: .automatic) {
            Button {
                showingAddExercise = true
            } label: {
                Label("Add Exercise", systemImage: "plus")
            }
        }

        // Finish
        ToolbarItem(placement: .confirmationAction) {
            Button("Finish") {
                showingFinishSheet = true
            }
            .bold()
        }
    }

    // MARK: - Finish sheet

    private var finishWorkoutSheet: some View {
        NavigationStack {
            Form {
                Section("Summary") {
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text("\(manager.currentSession?.durationMinutes ?? 0) min")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Exercises")
                        Spacer()
                        Text("\(uniqueExerciseCount)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Total Sets")
                        Spacer()
                        Text("\(manager.currentSession?.totalSets ?? 0)")
                            .foregroundStyle(.secondary)
                    }
                    if let volume = manager.currentSession?.totalVolume, volume > 0 {
                        HStack {
                            Text("Total Volume")
                            Spacer()
                            Text("\(Int(volume)) kg")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Finish Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Keep Going") {
                        showingFinishSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save & Finish") {
                        manager.finishWorkout()
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }

    // MARK: - Add exercise sheet

    private var addExerciseSheet: some View {
        NavigationStack {
            ExercisePickerView { exercise in
                manager.addExercise(exercise)
                showingAddExercise = false
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAddExercise = false
                    }
                }
            }
        }
    }

    // Helper: unique exercise count
    private var uniqueExerciseCount: Int {
        guard let session = manager.currentSession else { return 0 }
        return Set(session.sets.compactMap { $0.exercise?.id }).count
    }
}

// MARK: - ExercisePickerView
// Simple exercise picker sheet for adding exercises mid-workout
struct ExercisePickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [Exercise]

    let onSelect: (Exercise) -> Void

    @State private var searchText = ""

    var body: some View {
        List {
            ForEach(filteredExercises) { exercise in
                Button {
                    onSelect(exercise)
                } label: {
                    HStack {
                        MuscleGroupIcon(muscleGroup: exercise.muscleGroup, size: 20)

                        VStack(alignment: .leading) {
                            Text(exercise.name)
                                .foregroundStyle(.primary)

                            Text("\(exercise.muscleGroup.rawValue) · \(exercise.category.rawValue)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.appAccent)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search exercises")
    }

    private var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        }
        return exercises.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}
