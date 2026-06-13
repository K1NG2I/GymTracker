import WidgetKit
import SwiftUI
import SwiftData

// MARK: - GymTrackerWidget
// A simple widget that shows the last completed workout summary.
// Users can add this to their home screen for a quick glance.
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), lastWorkoutSummary: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), lastWorkoutSummary: "Last: Full Body · 12 sets")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        // In a real widget, you'd fetch from SwiftData shared container
        let entry = SimpleEntry(date: Date(), lastWorkoutSummary: nil)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let lastWorkoutSummary: String?
}

struct GymTrackerWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(.orange)
                Text("GymTracker")
                    .font(.headline)
            }

            if let summary = entry.lastWorkoutSummary {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("No recent workouts")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Start a new session!")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct GymTrackerWidget: Widget {
    let kind: String = "GymTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GymTrackerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Last Workout")
        .description("Shows a summary of your most recent workout.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    GymTrackerWidget()
} timeline: {
    SimpleEntry(date: Date(), lastWorkoutSummary: "Last: Full Body · 12 sets")
    SimpleEntry(date: Date(), lastWorkoutSummary: nil)
}
