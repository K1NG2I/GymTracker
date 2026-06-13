import SwiftUI
import SwiftData
import Charts

// MARK: - ExerciseProgressView
// Shows progress for a single exercise over time.
// Weight per set, volume, and rep count charts.
struct ExerciseProgressView: View {
    let exercise: Exercise

    @Query private var allSets: [ExerciseSet]

    init(exercise: Exercise) {
        self.exercise = exercise
        let id = exercise.persistentModelID
        // Fetch sets for this exercise, ordered by completion date
        _allSets = Query(filter: #Predicate<ExerciseSet> { set in
            set.exercise?.persistentModelID == id && !set.isWarmup
        }, sort: \ExerciseSet.completedAt, order: .forward)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Weight progression chart
                weightChartSection

                // Volume progression chart
                volumeChartSection

                // Rep count chart
                repsChartSection

                // Stats summary
                statsSection
            }
            .padding()
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Weight chart

    private var weightChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weight Progression")
                .font(.headline)

            Chart {
                ForEach(Array(allSets.enumerated()), id: \.offset) { index, set in
                    PointMark(
                        x: .value("Set #", index + 1),
                        y: .value("Weight", set.weight)
                    )
                    .foregroundStyle(Color.appAccent.gradient)

                    LineMark(
                        x: .value("Set #", index + 1),
                        y: .value("Weight", set.weight)
                    )
                    .foregroundStyle(Color.appAccent.gradient.opacity(0.5))
                }
            }
            .chartXAxisLabel("Workout (chronological)")
            .chartYAxisLabel("Weight (kg)")
            .frame(height: 180)
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Volume chart

    private var volumeChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Volume (Weight × Reps)")
                .font(.headline)

            Chart {
                ForEach(Array(allSets.enumerated()), id: \.offset) { index, set in
                    BarMark(
                        x: .value("Set #", index + 1),
                        y: .value("Volume", set.weight * Double(set.reps))
                    )
                    .foregroundStyle(Color.appAccent.gradient.opacity(0.7))
                }
            }
            .chartXAxisLabel("Workout (chronological)")
            .chartYAxisLabel("Volume")
            .frame(height: 180)
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Reps chart

    private var repsChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rep Count")
                .font(.headline)

            Chart {
                ForEach(Array(allSets.enumerated()), id: \.offset) { index, set in
                    PointMark(
                        x: .value("Set #", index + 1),
                        y: .value("Reps", set.reps)
                    )
                    .foregroundStyle(Color.green.gradient)
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic)
            }
            .chartXAxisLabel("Workout (chronological)")
            .chartYAxisLabel("Reps")
            .frame(height: 160)
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Stats")
                .font(.headline)

            let bestSet = allSets.max(by: { ($0.weight * Double($0.reps)) < ($1.weight * Double($1.reps)) })
            let heaviestWeight = allSets.max(by: { $0.weight < $1.weight })
            let totalSets = allSets.count
            let totalVolume = allSets.reduce(0) { $0 + $1.weight * Double($1.reps) }

            Group {
                if let best = bestSet {
                    statRow(label: "Best Set", value: "\(best.reps) reps × \(String(format: "%.1f", best.weight)) kg")
                }
                if let heaviest = heaviestWeight {
                    statRow(label: "Heaviest Weight", value: "\(String(format: "%.1f", heaviest.weight)) kg")
                }
                statRow(label: "Total Sets", value: "\(totalSets)")
                statRow(label: "Total Volume", value: "\(Int(totalVolume)) kg")
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
        .font(.subheadline)
    }
}
