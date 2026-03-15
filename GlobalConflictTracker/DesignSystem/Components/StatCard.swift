import SwiftUI

/// Large metric card with trend indicator
/// Shows: label, large value, trend arrow + percentage
/// Used in: Faction Profile
struct StatCard: View {
    let label: String
    let value: String
    let trend: Double
    let icon: String

    /// Full labels for abbreviations (tooltips)
    private var trendLabel: String {
        if trend > 0 {
            return "+\(String(format: "%.1f", trend))%"
        } else if trend < 0 {
            return "\(String(format: "%.1f", trend))%"
        }
        return "0.0%"
    }

    private var trendColor: Color {
        if trend > 0 { return AppColors.success }
        if trend < 0 { return AppColors.danger }
        return AppColors.textSecondary
    }

    private var trendIcon: String {
        trend >= 0 ? "arrow.up.right" : "arrow.down.right"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text(label)
                    .font(AppTypography.caption)
                    .tracking(AppTypography.trackingWide)
                    .textCase(.uppercase)
                    .foregroundStyle(AppColors.textSecondary)

                Spacer()

                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textTertiary)
            }

            Text(value)
                .font(AppTypography.displayLarge)
                .foregroundStyle(AppColors.textPrimary)
                .fontDesign(.default)

            HStack(spacing: AppSpacing.xs) {
                Image(systemName: trendIcon)
                    .font(.system(size: 11, weight: .semibold))

                Text(trendLabel)
                    .font(AppTypography.caption)
            }
            .foregroundStyle(trendColor)
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

#Preview("Stat Cards") {
    VStack(spacing: 16) {
        StatCard(label: "Personnel", value: "1.2M", trend: 0.5, icon: "person.2.fill")
        StatCard(label: "Fleet Strength", value: "340K", trend: -1.2, icon: "shield.fill")
        StatCard(label: "Air Assets", value: "320K", trend: 0.8, icon: "airplane")
    }
    .padding()
    .background(AppColors.background)
}
