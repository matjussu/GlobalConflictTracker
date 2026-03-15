import SwiftUI

/// Sector summary card at the bottom of Factions Directory
/// Matches Figma node 1:198 bottom section
struct SectorSummaryCard: View {
    let factionCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Sector Summary")

            ZStack(alignment: .bottomLeading) {
                // Background gradient
                RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.surface,
                                Color(red: 0.08, green: 0.12, blue: 0.06),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 140)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("\(factionCount) FORCES TRACKED")
                        .font(AppTypography.labelLarge)
                        .tracking(AppTypography.trackingWide)
                        .foregroundStyle(AppColors.textSecondary)

                    Text("GLOBAL MONITORING ACTIVE")
                        .font(AppTypography.caption)
                        .tracking(AppTypography.trackingWide)
                        .foregroundStyle(AppColors.accent)
                }
                .padding(AppSpacing.md)
            }
        }
    }
}

#Preview {
    SectorSummaryCard(factionCount: 6)
        .padding()
        .background(AppColors.background)
        .preferredColorScheme(.dark)
}
