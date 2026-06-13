import SwiftUI
import SwiftData

// MARK: - HistoryListView
// Tab 4: Browse past workout sessions, grouped by date.
struct HistoryListView: View {
    @Query(sort: \WorkoutSession.startedAt, order: .reverse)
    private var sessions: [WorkoutSession]

    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    EmptyStateView.noWorkouts()
                } else {
                    List {
                        // Group sessions by month
                        let grouped = Dictionary(grouping: filteredSessions) { session in
                            monthYearFormatter.string(from: session.startedAt)
                        }
                        let sortedMonths = grouped.keys.sorted(by: >)

                        ForEach(sortedMonths, id: \.self) { month in
                            Section(month) {
                                ForEach(grouped[month]!) { session in
                                    NavigationLink {
                                        SessionDetailView(session: session)
                                    } label: {
                                        HistoryRow(session: session)
                                    }
                                }
                                .onDelete { offsets in
                                    for offset in offsets {
                                        let sessionToDelete = grouped[month]![offset]
                                        sessionToDelete.sets.forEach {
                                            sessionToDelete.modelContext?.delete($0)
                                        }
                                        sessionToDelete.modelContext?.delete(sessionToDelete)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .searchable(text: $searchText, prompt: "Search workouts")
        }
    }

    private var filteredSessions: [WorkoutSession] {
        if searchText.isEmpty { return sessions }
        return sessions.filter {
            $0.template?.name.localizedCaseInsensitiveContains(searchText) ?? false ||
            $0.notes.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var monthYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()
}

// MARK: - HistoryRow
struct HistoryRow: View {
    let session: WorkoutSession

    var body: some View {
        HStack(spacing: 12) {
            // Date indicator
            VStack(spacing: 2) {
                Text(session.startedAt, format: .dateTime.day())
                    .font(.title3.bold())
                Text(session.startedAt, format: .dateTime.weekday(.abbreviated))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 40)

            Divider()
                .frame(height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(session.template?.name ?? "Free Session")
                    .font(.body.bold())

                HStack(spacing: 8) {
                    Label("\(session.totalSets) sets", systemImage: "number")
                    Label("\(session.durationMinutes)m", systemImage: "clock")
                    if session.totalVolume > 0 {
                        Label("\(Int(session.totalVolume)) kg", systemImage: "scalemass")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if session.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}
