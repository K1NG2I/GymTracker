import SwiftUI
import SwiftData

// MARK: - CreateTemplateView
// Sheet for creating a new workout template.
// User names the template and picks exercises with default set/rep config.
struct CreateTemplateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var templateName: String = ""
    @State private var templateDescription: String = ""

    // All exercises available in the library
    @Query private var allExercises: [Exercise]

    // Selected exercises with their config
    @State private var selectedExercises: [TemplateExerciseConfig] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Template Info") {
                    TextField("Template Name", text: $templateName)

                    TextField("Description (optional)", text: $templateDescription, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Exercises") {
                    if selectedExercises.isEmpty {
                        Text("Tap + to add exercises")
                            .foregroundStyle(.secondary)
                    }

                    ForEach(selectedExercises.indices, id: \.self) { index in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(selectedExercises[index].exercise.name)
                                    .font(.body)

                                HStack {
                                    Stepper("\(selectedExercises[index].sets) sets",
                                            value: $selectedExercises[index].sets,
                                            in: 1...10)

                                    Text("\(selectedExercises[index].minReps)-\(selectedExercises[index].maxReps) reps")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete { offsets in
                        selectedExercises.remove(atOffsets: offsets)
                    }
                    .onMove { from, to in
                        selectedExercises.move(fromOffsets: from, toOffset: to)
                    }

                    // Add exercise button
                    NavigationLink {
                        ExerciseMultiPickerView(selectedExercises: $selectedExercises, allExercises: allExercises)
                    } label: {
                        Label("Add Exercise", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveTemplate)
                        .bold()
                        .disabled(templateName.trimmingCharacters(in: .whitespaces).isEmpty || selectedExercises.isEmpty)
                }
                ToolbarItem(placement: .automatic) {
                    EditButton()
                }
            }
        }
    }

    private func saveTemplate() {
        let name = templateName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, !selectedExercises.isEmpty else { return }

        let template = WorkoutTemplate(
            name: name,
            description: templateDescription,
            isBuiltIn: false
        )
        modelContext.insert(template)

        for (index, config) in selectedExercises.enumerated() {
            let te = TemplateExercise(
                order: index,
                defaultSets: config.sets,
                defaultMinReps: config.minReps,
                defaultMaxReps: config.maxReps,
                exercise: config.exercise
            )
            te.template = template
            modelContext.insert(te)
            template.exercises.append(te)
        }

        try? modelContext.save()
        dismiss()
    }
}

// MARK: - TemplateExerciseConfig
// Temporary config for building a template before saving.
struct TemplateExerciseConfig: Identifiable {
    let id = UUID()
    let exercise: Exercise
    var sets: Int = 3
    var minReps: Int = 8
    var maxReps: Int = 12
}

// MARK: - ExerciseMultiPickerView
// Allows selecting multiple exercises to add to a template.
struct ExerciseMultiPickerView: View {
    @Binding var selectedExercises: [TemplateExerciseConfig]
    let allExercises: [Exercise]

    @State private var searchText = ""

    var body: some View {
        let alreadySelectedIDs = Set(selectedExercises.map { $0.exercise.id })
        let available = allExercises.filter { !alreadySelectedIDs.contains($0.id) }

        List {
            if searchText.isEmpty {
                let grouped = Dictionary(grouping: available) { $0.muscleGroup }
                ForEach(grouped.keys.sorted { $0.rawValue < $1.rawValue }, id: \.self) { group in
                    Section(group.rawValue) {
                        ForEach(grouped[group]!.sorted { $0.name < $1.name }) { exercise in
                            Button {
                                selectedExercises.append(TemplateExerciseConfig(exercise: exercise))
                            } label: {
                                HStack {
                                    MuscleGroupIcon(muscleGroup: exercise.muscleGroup, size: 18)
                                    Text(exercise.name)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Image(systemName: "plus.circle")
                                        .foregroundStyle(Color.appAccent)
                                }
                            }
                        }
                    }
                }
            } else {
                let filtered = available.filter {
                    $0.name.localizedCaseInsensitiveContains(searchText)
                }
                ForEach(filtered) { exercise in
                    Button {
                        selectedExercises.append(TemplateExerciseConfig(exercise: exercise))
                    } label: {
                        HStack {
                            MuscleGroupIcon(muscleGroup: exercise.muscleGroup, size: 18)
                            Text(exercise.name)
                            Spacer()
                            Image(systemName: "plus.circle")
                                .foregroundStyle(Color.appAccent)
                        }
                    }
                }
            }
        }
        .navigationTitle("Pick Exercises")
        .searchable(text: $searchText, prompt: "Search")
    }
}
