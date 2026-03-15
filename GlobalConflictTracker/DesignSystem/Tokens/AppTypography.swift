import SwiftUI

enum AppTypography {

    // MARK: - Display (Large titles, hero metrics)

    /// Large metric numbers (e.g. "1.2M", "340K")
    static let displayLarge = Font.system(size: 36, weight: .bold, design: .default)
    /// Screen titles (e.g. "INTEL FEED")
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .default)

    // MARK: - Headings

    /// Section heading (e.g. "Naval Deployment in Red Sea")
    static let heading1 = Font.system(size: 22, weight: .bold, design: .default)
    /// Card titles, list item titles
    static let heading2 = Font.system(size: 18, weight: .semibold, design: .default)
    /// Subtitle / sub-heading
    static let heading3 = Font.system(size: 16, weight: .semibold, design: .default)

    // MARK: - Body

    /// Primary body text
    static let body = Font.system(size: 15, weight: .regular, design: .default)
    /// Secondary body text
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)

    // MARK: - Labels (uppercase tracking)

    /// Section header labels (e.g. "GLOBAL DIRECTORY", "OPERATIONAL REGIONS")
    static let labelLarge = Font.system(size: 12, weight: .semibold, design: .default)
    /// Badge labels (e.g. "CRITICAL", "HIGH ALERT")
    static let labelSmall = Font.system(size: 10, weight: .bold, design: .default)
    /// Metadata (timestamps, sector labels)
    static let caption = Font.system(size: 11, weight: .medium, design: .default)

    // MARK: - Tracking (letter spacing)

    /// Extended tracking for military-style uppercase labels
    static let trackingWide: CGFloat = 2.0
    /// Standard tracking for headings
    static let trackingNormal: CGFloat = 0.5
}

// MARK: - View Extension for tracked text

extension View {
    func tacticalLabel() -> some View {
        self
            .font(AppTypography.labelLarge)
            .tracking(AppTypography.trackingWide)
            .foregroundStyle(AppColors.textSecondary)
            .textCase(.uppercase)
    }

    func sectionHeaderStyle() -> some View {
        self
            .font(AppTypography.labelLarge)
            .tracking(AppTypography.trackingWide)
            .foregroundStyle(AppColors.textSecondary)
            .textCase(.uppercase)
    }
}
