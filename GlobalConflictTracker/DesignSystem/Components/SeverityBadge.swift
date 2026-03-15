import SwiftUI

/// Tactical severity badge — "CRITICAL", "HIGH ALERT", "WARNING"
/// Used in: Tactical Map, Intel Feed, Event Detail
struct SeverityBadge: View {
    let severity: Severity

    var body: some View {
        Text(severity.label)
            .font(AppTypography.labelSmall)
            .tracking(AppTypography.trackingWide)
            .textCase(.uppercase)
            .foregroundStyle(.white)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(AppColors.severityColor(severity))
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusSmall))
    }
}

#Preview("All Severities") {
    VStack(spacing: 12) {
        SeverityBadge(severity: .critical)
        SeverityBadge(severity: .warning)
        SeverityBadge(severity: .low)
    }
    .padding()
    .background(AppColors.background)
}
