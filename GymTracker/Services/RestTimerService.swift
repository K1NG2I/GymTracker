import Foundation
import Observation
import UIKit

// MARK: - RestTimerService
// Observable service that manages a countdown timer between sets.
// Provides haptic feedback when the timer expires.
@Observable
final class RestTimerService {

    // The current countdown value in seconds (displayed in the UI)
    var remainingSeconds: Int = 0

    // The total duration of the current timer in seconds
    var totalSeconds: Int = 0

    // Whether the timer is currently running
    var isRunning: Bool = false

    // Whether the timer has completed (reached zero)
    var isFinished: Bool = false

    // The default rest duration, in seconds. User-configurable.
    var defaultRestDuration: Int {
        get { UserDefaults.standard.integer(forKey: "defaultRestDuration").nonZero(or: 90) }
        set { UserDefaults.standard.set(newValue, forKey: "defaultRestDuration") }
    }

    // The underlying Timer publisher
    private var timer: Timer?

    // MARK: - Timer controls

    /// Start the rest timer with the default duration.
    func start() {
        start(duration: defaultRestDuration)
    }

    /// Start the rest timer with a specific duration (in seconds).
    func start(duration: Int) {
        stop() // cancel any existing timer

        totalSeconds = max(duration, 10) // minimum 10 seconds
        remainingSeconds = totalSeconds
        isRunning = true
        isFinished = false

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            } else {
                self.timerExpired()
            }
        }
    }

    /// Pause the timer.
    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    /// Resume the timer from where it was paused.
    func resume() {
        guard remainingSeconds > 0 else { return }
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            } else {
                self.timerExpired()
            }
        }
    }

    /// Stop the timer and reset.
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        remainingSeconds = 0
        isFinished = false
    }

    /// Skip/restart the timer (user tapped "Skip Rest").
    func skip() {
        stop()
    }

    // MARK: - Private helpers

    private func timerExpired() {
        stop()
        isFinished = true

        // Haptic feedback to alert the user
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }

    /// Format remaining seconds as mm:ss
    var timeDisplay: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Progress from 0.0 to 1.0
    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }
}

// MARK: - Helper extension
private extension Int {
    func nonZero(or defaultValue: Int) -> Int {
        self == 0 ? defaultValue : self
    }
}
