import SwiftUI
import SwiftData
import Charts

// MARK: - ProgressHomeView
// Tab 5: Overview of training progress.
// Shows volume over time, most trained muscle groups, and personal records.
struct ProgressHomeView: View {
    @Query(sort: \WorkoutSession.startedAt, order: .reverse)
    private var sessions: [WorkoutSession]

    @Query private var exercises: [Exercise]

    // Selected time range for volume chart
    @State private var selectedRange: TimeRange = .month

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Volume over time chart
                    if !sessions.isEmpty {
                        volumeChartSection

                        // Most trained muscle groups
                        muscleGroupDistributionSection

                        // Personal records
                        personalRecordsSection
                    } else {
                        EmptyStateView(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "No Progress Yet",
                            message: "Complete a few workouts to see your progress here."
                        )
                        .padding(.top, 60)
                    }
                }
            }
            .navigationTitle("Progress")
        }
    }

    // MARK: - Volume chart

    private var volumeChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Volume Over Time")
                    .font(.headline)

                Spacer()

                // Time range picker
                Picker("Range", selection: $selectedRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }

            let chartData = volumeChartData

            Chart(chartData, id: \.date) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Volume", point.volume)
                )
                .foregroundStyle(Color.appAccent.gradient)

                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Volume", point.volume)
                )
                .foregroundStyle(Color.appAccent.opacity(0.1).gradient)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel(format: .dateTime.day().month())
                }
            }
            .chartYAxisLabel("Volume (kg)")
            .frame(height: 200)
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private var volumeChartData: [(date: Date, volume: Double)] {
        let startDate: Date
        switch selectedRange {
        case .week:  startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case .month: startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case .year:  startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        case .all:   startDate = Date.distantPast
        }

        let filteredSessions = sessions
            .filter { $0.isCompleted && $0.startedAt >= startDate }
            .sorted { $0.startedAt < $1.startedAt }

        return filteredSessions.map { session in
            (date: session.startedAt, volume: session.totalVolume)
        }
    }

    // MARK: - Muscle group distribution

    private var muscleGroupDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Muscle Group Distribution")
                .font(.headline)

            let data = muscleGroupData

            Chart(data, id: \.group) { item in
                SectorMark(
                    angle: .value("Sets", item.count),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(Color.muscleGroupColor(item.group))
                .annotation(position: .overlay) {
                    if item.count > 0 {
                        Text("\(item.count)")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                    }
                }
            }
            .frame(height: 200)

            // Legend
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 4) {
                ForEach(data, id: \.group) { item in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.muscleGroupColor(item.group))
                            .frame(width: 8, height: 8)
                        Text("\(item.group.rawValue): \(item.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private var muscleGroupData: [(group: MuscleGroup, count: Int)] {
        var counts: [MuscleGroup: Int] = [:]
        for session in sessions where session.isCompleted {
            for set in session.sets where !set.isWarmup {
                if let group = set.exercise?.muscleGroup {
                    counts[group, default: 0] += 1
                }
            }
        }
        return counts.map { ($0.key, $0.value) }.sorted(by: { $0.1 > $1.1 })
    }

    // MARK: - Personal records

    private var personalRecordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Personal Records")
                .font(.headline)

            let prs = calculatePRs()

            if prs.isEmpty {
                Text("No PRs yet. Keep training!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                let topPRs = Array(prs.prefix(5))
                ForEach(topPRs) { pr in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pr.exerciseName)
                                .font(.subheadline.bold())

                            Text("\(String(format: "%.1f", pr.weight)) kg × \(pr.reps) reps")
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(Color.appAccent)

                            if let date = pr.date {
                                Text(date.workoutDateString)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }

                        Spacer()

                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private struct PRRecord: Identifiable {
        let id = UUID()
        let exerciseName: String
        let weight: Double
        let reps: Int
        let date: Date?
    }

    private func calculatePRs() -> [PRRecord] {
        // Group sets by exercise and find the highest estimated 1RM (Epley formula)
        // Or simply max weight × reps
        var bestByExercise: [String: (weight: Double, reps: Int, date: Date?)] = [:]

        for session in sessions where session.isCompleted {
            for set in session.sets where !set.isWarmup {
                guard let name = set.exercise?.name else { continue }

                if let existing = bestByExercise[name] {
                    // Compare simple volume metric (weight × reps)
                    let currentScore = set.weight * Double(set.reps)
                    let existingScore = existing.weight * Double(existing.reps)
                    if currentScore > existingScore {
                        bestByExercise[name] = (set.weight, set.reps, set.completedAt)
                    }
                } else {
                    bestByExercise[name] = (set.weight, set.reps, set.completedAt)
                }
            }
        }

        return bestByExercise.map {
            PRRecord(exerciseName: $0.key, weight: $0.value.weight, reps: $0.value.reps, date: $0.value.date)
        }
        .sorted { $0.weight * Double($0.reps) > $1.weight * Double($1.reps) }
    }
}

// MARK: - Time range enum
enum TimeRange: String, CaseIterable {
    case week  = "Week"
    case month = "Month"
    case year  = "Year"
    case all   = "All"
}
