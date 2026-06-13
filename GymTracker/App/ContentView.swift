import SwiftUI

// MARK: - ContentView
// The root view with a 5-tab layout:
// 1. Workout — start/active/log
// 2. Library — browse exercises
// 3. Templates — manage routines
// 4. History — past sessions
// 5. Progress — charts and stats
struct ContentView: View {
    // Track which tab is selected
    @State private var selectedTab: Tab = .workout

    enum Tab: String, CaseIterable {
        case workout  = "Workout"
        case library  = "Library"
        case templates = "Templates"
        case history  = "History"
        case progress = "Progress"

        var icon: String {
            switch self {
            case .workout:   return "figure.run"
            case .library:   return "dumbbell"
            case .templates: return "list.bullet.clipboard"
            case .history:   return "clock.arrow.circlepath"
            case .progress:  return "chart.line.uptrend.xyaxis"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Workout
            WorkoutHomeView()
                .tabItem {
                    VStack(spacing: 2) {
                        Image(systemName: Tab.workout.icon)
                            .font(.system(size: 18))
                        Text(Tab.workout.rawValue)
                            .font(.system(size: 10))
                    }
                }
                .tag(Tab.workout)

            // Tab 2: Exercise Library
            ExerciseListView()
                .tabItem {
                    VStack(spacing: 2) {
                        Image(systemName: Tab.library.icon)
                            .font(.system(size: 18))
                        Text(Tab.library.rawValue)
                            .font(.system(size: 10))
                    }
                }
                .tag(Tab.library)

            // Tab 3: Templates
            TemplateListView()
                .tabItem {
                    VStack(spacing: 2) {
                        Image(systemName: Tab.templates.icon)
                            .font(.system(size: 18))
                        Text(Tab.templates.rawValue)
                            .font(.system(size: 10))
                    }
                }
                .tag(Tab.templates)

            // Tab 4: History
            HistoryListView()
                .tabItem {
                    VStack(spacing: 2) {
                        Image(systemName: Tab.history.icon)
                            .font(.system(size: 18))
                        Text(Tab.history.rawValue)
                            .font(.system(size: 10))
                    }
                }
                .tag(Tab.history)

            // Tab 5: Progress
            ProgressHomeView()
                .tabItem {
                    VStack(spacing: 2) {
                        Image(systemName: Tab.progress.icon)
                            .font(.system(size: 18))
                        Text(Tab.progress.rawValue)
                            .font(.system(size: 10))
                    }
                }
                .tag(Tab.progress)
        }
        .tabViewStyle(.tabBarOnly)
        .tint(.appAccent)
    }
}

#Preview {
    ContentView()
}
