import SwiftUI
import SwiftData

// MARK: - ExerciseListView
// Tab 2: Browse all exercises in the library.
// Grouped by muscle group. Supports search and filtering.
struct ExerciseListView: View {
    @Query private var exercises: [Exercise]
    @State private var searchText = ""
    @State private var selectedMuscleGroup: MuscleGroup?
    @State private var showingCreate = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Muscle group filter chips
                muscleGroupFilter

                // Exercise list
                exerciseList
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreate = true
                    } label: {
                        Label("New Exercise", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreate) {
                CreateExerciseView()
            }
        }
    }

    // MARK: - Muscle group filter

    private var muscleGroupFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All" option
                Button {
                    selectedMuscleGroup = nil
                } label: {
                    Text("All")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedMuscleGroup == nil ? Color.appAccent : Color.cardBackground)
                        .foregroundStyle(selectedMuscleGroup == nil ? .white : .primary)
                        .clipShape(Capsule())
                }

                ForEach(MuscleGroup.allCases, id: \.self) { group in
                    Button {
                        selectedMuscleGroup = group
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: group.iconName)
                                .font(.caption)
                            Text(group.rawValue)
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedMuscleGroup == group ? Color.appAccent : Color.cardBackground)
                        .foregroundStyle(selectedMuscleGroup == group ? .white : .primary)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Exercise list

    private var exerciseList: some View {
        let filtered = filteredExercises

        // Group by muscle group
        let grouped = Dictionary(grouping: filtered) { $0.muscleGroup }
        let sortedKeys = grouped.keys.sorted { $0.rawValue < $1.rawValue }

        return Group {
            if filtered.isEmpty {
                EmptyStateView.noExercises()
            } else {
                List {
                    ForEach(sortedKeys, id: \.self) { group in
                        Section {
                            ForEach(grouped[group]!.sorted { $0.name < $1.name }) { exercise in
                                NavigationLink {
                                    ExerciseDetailView(exercise: exercise)
                                } label: {
                                    exerciseRow(exercise)
                                }
                            }
                        } header: {
                            HStack(spacing: 8) {
                                Image(systemName: group.iconName)
                                    .foregroundStyle(Color.muscleGroupColor(group))
                                Text(group.rawValue)
                                    .font(.headline)
                                Text("(\(grouped[group]!.count))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search exercises")
    }

    // MARK: - Exercise row

    private func exerciseRow(_ exercise: Exercise) -> some View {
        HStack {
            MuscleGroupIcon(muscleGroup: exercise.muscleGroup, size: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.body)

                HStack(spacing: 8) {
                    Text(exercise.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(exercise.repRange.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())

                    if exercise.isCustom {
                        Text("Custom")
                            .font(.caption2)
                            .foregroundStyle(Color.appAccent)
                    }
                }
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Filtering

    private var filteredExercises: [Exercise] {
        var result = exercises

        // Filter by muscle group
        if let group = selectedMuscleGroup {
            result = result.filter { $0.muscleGroup == group }
        }

        // Search text
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.muscleGroup.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }
}

// MARK: - ExerciseDetailView
// Shows details for a single exercise and its history.
struct ExerciseDetailView: View {
    let exercise: Exercise

    // Past sets for this exercise
    @Query private var allSets: [ExerciseSet]

    init(exercise: Exercise) {
        self.exercise = exercise
        // Filter sets for this exercise
        let exerciseID = exercise.persistentModelID
        _allSets = Query(filter: #Predicate<ExerciseSet> { set in
            set.exercise?.persistentModelID == exerciseID
        }, sort: \ExerciseSet.completedAt, order: .reverse)
    }

    var body: some View {
        List {
            // Info section
            Section("Details") {
                HStack {
                    MuscleGroupIcon(muscleGroup: exercise.muscleGroup)
                    VStack(alignment: .leading) {
                        Text("Target Muscle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(exercise.muscleGroup.rawValue)
                    }
                }

                HStack {
                    Image(systemName: "wrench")
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading) {
                        Text("Equipment")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(exercise.category.rawValue)
                    }
                }

                HStack {
                    Image(systemName: "target")
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading) {
                        Text("Goal Rep Range")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(exercise.repRange.description)
                    }
                }

                if !exercise.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(exercise.notes)
                            .font(.body)
                    }
                }
            }

            // Recent sets
            Section("Recent Sets") {
                let recentSets = allSets.prefix(10)
                if recentSets.isEmpty {
                    Text("No sets logged for this exercise yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(recentSets) { set in
                        HStack {
                            Text("\(set.reps) reps × \(set.weight, specifier: "%.1f") kg")
                                .font(.body.monospacedDigit())

                            Spacer()

                            if let date = set.completedAt {
                                Text(date.workoutDateString)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.large)
    }
}
