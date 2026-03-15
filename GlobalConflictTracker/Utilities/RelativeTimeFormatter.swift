import Foundation

enum RelativeTimeFormatter {
    private static let formatter: Foundation.RelativeDateTimeFormatter = {
        let formatter = Foundation.RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    /// Returns a relative time string like "2h ago", "5m ago", "3d ago"
    static func string(from date: Date) -> String {
        formatter.localizedString(for: date, relativeTo: .now)
    }

    /// Returns both relative and absolute UTC time
    /// e.g. "2h ago • 04:12 UTC"
    static func fullString(from date: Date) -> String {
        let relative = string(from: date)
        let utc = utcString(from: date)
        return "\(relative) • \(utc)"
    }

    /// Returns UTC formatted time like "04:12 UTC"
    static func utcString(from date: Date) -> String {
        let utcFormatter = DateFormatter()
        utcFormatter.dateFormat = "HH:mm"
        utcFormatter.timeZone = TimeZone(identifier: "UTC")
        return "\(utcFormatter.string(from: date)) UTC"
    }
}
