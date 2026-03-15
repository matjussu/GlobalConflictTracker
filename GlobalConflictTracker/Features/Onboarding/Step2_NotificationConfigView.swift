import SwiftUI

struct Step2_NotificationConfigView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Spacer(minLength: AppSpacing.xxl)

                Text("Configure\nAlerts")
                    .font(AppTypography.displayMedium)
                    .foregroundStyle(AppColors.textPrimary)

                Text("Set up your notification preferences to stay informed about critical developments in real-time.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(4)

                VStack(spacing: AppSpacing.sm) {
                    SectionHeader(title: "Notification Settings")
                        .padding(.bottom, AppSpacing.xs)

                    notificationToggle(
                        icon: "bell.fill",
                        title: "Push Notifications",
                        description: "Receive alerts when new events are detected",
                        isOn: $viewModel.notificationsEnabled
                    )

                    notificationToggle(
                        icon: "exclamationmark.triangle.fill",
                        title: "Critical Alerts",
                        description: "High-priority alerts that bypass Do Not Disturb",
                        isOn: $viewModel.criticalAlertsEnabled
                    )
                }
                .padding(.top, AppSpacing.md)

                // Info callout
                HStack(alignment: .top, spacing: AppSpacing.sm) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.textTertiary)
                        .padding(.top, 2)

                    Text("You can change these settings at any time in the System tab.")
                        .font(AppTypography.bodySmall)
                        .foregroundStyle(AppColors.textTertiary)
                }
                .padding(.top, AppSpacing.md)

                Spacer(minLength: AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.md)
        }
        .scrollIndicators(.hidden)
    }

    private func notificationToggle(
        icon: String,
        title: String,
        description: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(isOn.wrappedValue ? AppColors.accent : AppColors.textTertiary)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.heading3)
                    .foregroundStyle(AppColors.textPrimary)

                Text(description)
                    .font(AppTypography.bodySmall)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(AppColors.accent)
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

#Preview {
    Step2_NotificationConfigView(viewModel: OnboardingViewModel())
        .background(AppColors.background)
        .preferredColorScheme(.dark)
}
