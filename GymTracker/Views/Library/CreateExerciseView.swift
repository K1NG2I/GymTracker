import SwiftUI
import SwiftData

// MARK: - CreateExerciseView
// Form for creating a custom exercise.
// Presented as a sheet from the Library view.
struct CreateExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedMuscleGroup: MuscleGroup = .chest
    @State private var selectedCategory: ExerciseCategory = .dumbbell
    @State private var selectedRepRange: RepRange = .hypertrophy
    @State private var notes: String = ""
    @State private var showingValidationError = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Exercise Name", text: $name)

                    Picker("Muscle Group", selection: $selectedMuscleGroup) {
                        ForEach(MuscleGroup.allCases, id: \.self) { group in
                            HStack {
                                Image(systemName: group.iconName)
                                Text(group.rawValue)
                            }
                            .tag(group)
                        }
                    }

                    Picker("Equipment", selection: $selectedCategory) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                }

                Section("Training Goal") {
                    Picker("Rep Range", selection: $selectedRepRange) {
                        ForEach(RepRange.allCases, id: \.self) { range in
                            if range != .any {
                                VStack(alignment: .leading) {
                                    Text(range.rawValue)
                                    Text(range.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .tag(range)
                            }
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Notes (Optional)") {
                    TextField("Form cues, alternatives, etc.", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveExercise)
                        .bold()
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Missing Name", isPresented: $showingValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enter a name for the exercise.")
            }
        }
    }

    private func saveExercise() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            showingValidationError = true
            return
        }

        let exercise = Exercise(
            name: trimmedName,
            muscleGroup: selectedMuscleGroup,
            category: selectedCategory,
            repRange: selectedRepRange,
            isCustom: true,
            notes: notes
        )
        modelContext.insert(exercise)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    CreateExerciseView()
}
