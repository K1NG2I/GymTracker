import SwiftUI

// MARK: - RestTimerView
// Displays a circular countdown timer between sets.
// Shows the remaining time, a progress ring, and controls.
struct RestTimerView: View {
    @State private var restTimer = RestTimerService()

    // Quick-select durations
    let quickOptions = [60, 90, 120, 180]

    var body: some View {
        VStack(spacing: 16) {
            // Timer display
            ZStack {
                // Progress ring
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: restTimer.progress)
                    .stroke(Color.restTimer, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: restTimer.progress)

                // Time remaining
                VStack(spacing: 4) {
                    Text(restTimer.timeDisplay)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .contentTransition(.numericText(countsDown: true))

                    Text("rest")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 200, height: 200)

            // Controls
            HStack(spacing: 20) {
                // Skip button
                Button {
                    restTimer.skip()
                } label: {
                    Label("Skip", systemImage: "forward.fill")
                        .font(.body)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)

                // Pause/Resume
                if restTimer.isRunning {
                    Button {
                        restTimer.pause()
                    } label: {
                        Label("Pause", systemImage: "pause.fill")
                            .font(.body)
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                } else if restTimer.remainingSeconds > 0 {
                    Button {
                        restTimer.resume()
                    } label: {
                        Label("Resume", systemImage: "play.fill")
                            .font(.body)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.restTimer)
                }
            }

            // Quick-select durations (shown when timer not running)
            if !restTimer.isRunning && restTimer.remainingSeconds == 0 {
                HStack(spacing: 12) {
                    ForEach(quickOptions, id: \.self) { seconds in
                        Button("\(seconds / 60):00") {
                            restTimer.start(duration: seconds)
                        }
                        .buttonStyle(.bordered)
                        .tint(.restTimer)
                    }
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
    }
}

#Preview {
    RestTimerView()
}
