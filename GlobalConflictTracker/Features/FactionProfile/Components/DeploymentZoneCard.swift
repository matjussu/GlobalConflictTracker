import SwiftUI

/// Deployment zone card
/// Used in: Faction Profile
struct DeploymentZoneCard: View {
    let zoneName: String

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(AppColors.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(zoneName)
                    .font(AppTypography.heading3)
                    .foregroundStyle(AppColors.textPrimary)

                Text("ACTIVE ZONE")
                    .font(AppTypography.labelSmall)
                    .tracking(AppTypography.trackingWide)
                    .foregroundStyle(AppColors.textTertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .accessibilityLabel("Deployment zone: \(zoneName)")
    }
}

#Preview {
    VStack(spacing: 8) {
        DeploymentZoneCard(zoneName: "Middle East")
        DeploymentZoneCard(zoneName: "Pacific")
    }
    .padding()
    .background(AppColors.background)
    .preferredColorScheme(.dark)
}
