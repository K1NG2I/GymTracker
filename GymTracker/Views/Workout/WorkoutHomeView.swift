import SwiftUI
import SwiftData

// MARK: - WorkoutHomeView
// The first tab. Shows options to start a new workout.
// Displays "Start Free Workout" button and quick-start from recent template.
struct WorkoutHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var workoutManager = WorkoutManager()
    @State private var showingActiveWorkout = false
    @State private var showingTemplatePicker = false
    @State private var selectedTemplate: WorkoutTemplate?

    // Query all templates for quick start
    @Query(sort: \WorkoutTemplate.createdAt, order: .reverse)
    private var templates: [WorkoutTemplate]

    // Most recent completed workout for "resume" type display
    @Query(sort: \WorkoutSession.startedAt, order: .reverse)
    private var recentSessions: [WorkoutSession]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero section
                    heroSection

                    // Quick start buttons
                    VStack(spacing: 12) {
                        // Start free workout
                        Button {
                            workoutManager.startFreeWorkout(in: modelContext)
                            showingActiveWorkout = true
                        } label: {
                            Label("Free Session", systemImage: "figure.run")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.appAccent)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Start from template
                        Button {
                            showingTemplatePicker = true
                        } label: {
                            Label("Use a Template", systemImage: "list.bullet.clipboard")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.cardBackground)
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)

                    // Recent templates quick-start
                    if !templates.isEmpty {
                        recentTemplatesSection
                    }

                    // Last workout summary
                    if let lastSession = recentSessions.first(where: { $0.isCompleted }) {
                        lastWorkoutSection(session: lastSession)
                    }
                }
            }
            .navigationTitle("Workout")
            .sheet(isPresented: $showingActiveWorkout) {
                ActiveWorkoutView(manager: workoutManager)
            }
            .sheet(isPresented: $showingTemplatePicker) {
                templatePickerSheet
            }
        }
    }

    // MARK: - Hero section

    private var heroSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.appAccent)

            Text("Ready to train?")
                .font(.title2.bold())

            Text("Start a free session or pick a template")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 20)
    }

    // MARK: - Recent templates

    private var recentTemplatesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Start")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(templates.prefix(5)) { template in
                        Button {
                            selectedTemplate = template
                            workoutManager.startWorkout(from: template, in: modelContext)
                            showingActiveWorkout = true
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .font(.title2)
                                    .foregroundStyle(Color.appAccent)

                                Text(template.name)
                                    .font(.caption)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)

                                Text("\(template.exercises.count) exercises")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 100, height: 100)
                            .background(Color.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Last workout

    private func lastWorkoutSection(session: WorkoutSession) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Last Workout")
                .font(.headline)
                .padding(.horizontal)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.template?.name ?? "Free Session")
                        .font(.body.bold())

                    Text(session.startedAt.workoutDateString)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        Label("\(session.totalSets) sets", systemImage: "number")
                        Label("\(session.durationMinutes) min", systemImage: "clock")
                        if session.totalVolume > 0 {
                            Label("\(Int(session.totalVolume)) kg", systemImage: "scalemass")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }

    // MARK: - Template picker sheet

    private var templatePickerSheet: some View {
        NavigationStack {
            List {
                if templates.isEmpty {
                    EmptyStateView.noTemplates()
                }
                ForEach(templates) { template in
                    Button {
                        selectedTemplate = template
                        workoutManager.startWorkout(from: template, in: modelContext)
                        showingActiveWorkout = true
                        showingTemplatePicker = false
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.name)
                                .font(.body.bold())
                                .foregroundStyle(.primary)

                            Text("\(template.exercises.count) exercises")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if !template.templateDescription.isEmpty {
                                Text(template.templateDescription)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Choose Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingTemplatePicker = false
                    }
                }
            }
        }
    }
}

#Preview {
    WorkoutHomeView()
}
