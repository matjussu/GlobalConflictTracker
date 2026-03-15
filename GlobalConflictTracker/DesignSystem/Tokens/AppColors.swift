import SwiftUI

enum AppColors {

    // MARK: - Backgrounds
    /// Primary background — deep black (#0A0A0A)
    static let background = Color(red: 0.04, green: 0.04, blue: 0.04)
    /// Surface for cards, rows, sheets (#141414)
    static let surface = Color(red: 0.08, green: 0.08, blue: 0.08)
    /// Elevated surface for modals, overlays (#1C1C1E)
    static let surfaceElevated = Color(red: 0.11, green: 0.11, blue: 0.12)

    // MARK: - Accent
    /// Tactical red — primary accent (#E50000). WCAG AA compliant on dark backgrounds.
    static let accent = Color(red: 0.90, green: 0.0, blue: 0.0)
    /// Muted red for secondary accent states (#99000)
    static let accentMuted = Color(red: 0.60, green: 0.0, blue: 0.0)

    // MARK: - Text
    /// Primary text — white (#FFFFFF)
    static let textPrimary = Color.white
    /// Secondary text — medium gray (#8A8A8A)
    static let textSecondary = Color(red: 0.54, green: 0.54, blue: 0.54)
    /// Tertiary text — dimmed gray (#555555)
    static let textTertiary = Color(red: 0.33, green: 0.33, blue: 0.33)

    // MARK: - Semantic
    /// Success / positive trend (#00E85A)
    static let success = Color(red: 0.0, green: 0.91, blue: 0.35)
    /// Danger / negative trend (#FF3B30)
    static let danger = Color(red: 1.0, green: 0.23, blue: 0.19)
    /// Warning / moderate severity (#FF9500)
    static let warning = Color(red: 1.0, green: 0.58, blue: 0.0)

    // MARK: - Borders
    /// Subtle border (#1F1F1F)
    static let border = Color(red: 0.12, green: 0.12, blue: 0.12)
    /// Active/selected border — uses accent
    static let borderActive = accent

    // MARK: - Severity Colors
    static func severityColor(_ severity: Severity) -> Color {
        switch severity {
        case .critical: accent
        case .warning: warning
        case .low: textSecondary
        }
    }

    // MARK: - Source Reliability Colors
    static func reliabilityColor(_ score: Int) -> Color {
        switch score {
        case 8...10: success
        case 5...7: warning
        default: danger
        }
    }
}
