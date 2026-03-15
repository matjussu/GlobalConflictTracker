import SwiftUI

/// Status dot + label — "● Active Deployment", "Standby"
/// Used in: Factions Directory, Faction Profile
struct StatusIndicator: View {
    let status: DeploymentStatus

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            if status.isActive {
                Circle()
                    .fill(status.isActive ? AppColors.accent : AppColors.textTertiary)
                    .frame(width: 6, height: 6)
            }

            Text(status.label)
                .font(AppTypography.caption)
                .foregroundStyle(status.isActive ? AppColors.accent : AppColors.textSecondary)
        }
    }
}

#Preview("Status Indicators") {
    VStack(alignment: .leading, spacing: 12) {
        StatusIndicator(status: .activeDeployment)
        StatusIndicator(status: .standby)
        StatusIndicator(status: .borderOps)
        StatusIndicator(status: .maritimePatrol)
        StatusIndicator(status: .logisticsSupport)
        StatusIndicator(status: .domesticSecurity)
    }
    .padding()
    .background(AppColors.background)
}
