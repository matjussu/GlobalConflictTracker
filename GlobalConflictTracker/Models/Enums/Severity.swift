import Foundation

enum Severity: String, Codable, CaseIterable {
    case critical
    case warning
    case low

    var label: String {
        switch self {
        case .critical: "CRITICAL"
        case .warning: "HIGH ALERT"
        case .low: "LOW"
        }
    }
}
