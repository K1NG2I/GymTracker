import Foundation

// MARK: - Date Formatting Extensions
// Convenience formatters for displaying dates and durations.
extension Date {

    /// "Today", "Yesterday", or "Mon 15 Jun" style
    nonisolated(unsafe) static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .full
        return f
    }()

    /// "Mon 15 Jun"
    nonisolated(unsafe) static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE d MMM"
        return f
    }()

    /// "15 Jun 2024"
    nonisolated(unsafe) static let mediumDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy"
        return f
    }()

    /// "14:30"
    nonisolated(unsafe) static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    /// Returns a user-friendly string for the date
    var workoutDateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if calendar.isDate(self, equalTo: Date(), toGranularity: .weekOfYear) {
            return Self.shortDateFormatter.string(from: self)
        } else {
            return Self.mediumDateFormatter.string(from: self)
        }
    }

    /// Time string only (e.g. "14:30")
    var timeString: String {
        Self.timeFormatter.string(from: self)
    }
}

// MARK: - Duration formatting
extension TimeInterval {

    /// Format as "1h 23m" or "45m"
    var workoutDurationString: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
