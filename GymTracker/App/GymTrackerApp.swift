import SwiftUI
import SwiftData

// MARK: - GymTrackerApp
// The main entry point for the GymTracker app.
// Sets up the SwiftData model container and seeds data on first launch.
@main
struct GymTrackerApp: App {

    let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            Exercise.self,
            WorkoutTemplate.self,
            TemplateExercise.self,
            WorkoutSession.self,
            ExerciseSet.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }

        seedInitialData()
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                WorkoutHomeView()
                    .tabItem {
                        Label("Workout", systemImage: "figure.run")
                    }

                ExerciseListView()
                    .tabItem {
                        Label("Library", systemImage: "dumbbell")
                    }

                TemplateListView()
                    .tabItem {
                        Label("Templates", systemImage: "list.bullet.clipboard")
                    }

                HistoryListView()
                    .tabItem {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }

                ProgressHomeView()
                    .tabItem {
                        Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                    }
            }
        }
        .modelContainer(modelContainer)
    }

    private func seedInitialData() {
        Task { @MainActor in
            let service = SeedDataService(modelContainer: modelContainer)
            await service.ensureSeedData()
        }
    }
}
