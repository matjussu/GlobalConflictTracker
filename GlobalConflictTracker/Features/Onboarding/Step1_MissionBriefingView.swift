import SwiftUI

struct Step1_MissionBriefingView: View {
    let viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Spacer(minLength: AppSpacing.xxl)

                // App icon placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.surface)
                        .frame(width: 80, height: 80)

                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(AppColors.accent)
                }

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Mission\nBriefing")
                        .font(AppTypography.displayMedium)
                        .foregroundStyle(AppColors.textPrimary)

                    Text("Welcome to Global Conflict & Intelligence Tracker — your real-time tactical dashboard for monitoring military conflicts and geopolitical events worldwide.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineSpacing(4)
                }

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    featureRow(icon: "map.fill", title: "Tactical Map", description: "Real-time conflict visualization with live event markers")
                    featureRow(icon: "doc.text.fill", title: "Intel Feed", description: "Curated intelligence reports from verified sources")
                    featureRow(icon: "person.3.fill", title: "Factions", description: "Global military force directory with deployment data")
                    featureRow(icon: "bell.badge.fill", title: "Alerts", description: "Instant notifications for critical developments")
                }
                .padding(.top, AppSpacing.md)

                Spacer(minLength: AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.md)
        }
        .scrollIndicators(.hidden)
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(AppColors.accent)
                .frame(width: 40, height: 40)
                .background(AppColors.accent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMedium))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.heading3)
                    .foregroundStyle(AppColors.textPrimary)

                Text(description)
                    .font(AppTypography.bodySmall)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}

#Preview {
    Step1_MissionBriefingView(viewModel: OnboardingViewModel())
        .background(AppColors.background)
        .preferredColorScheme(.dark)
}
