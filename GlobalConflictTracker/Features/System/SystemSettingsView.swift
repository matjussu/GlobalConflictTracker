import SwiftUI

/// System / Settings tab
struct SystemSettingsView: View {
    @State private var viewModel = SystemSettingsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Header
                Text("System")
                    .font(AppTypography.displayMedium)
                    .foregroundStyle(AppColors.textPrimary)

                // Notifications section
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    SectionHeader(title: "Notifications")

                    toggleRow(
                        icon: "bell.fill",
                        title: "Push Notifications",
                        description: "Receive alerts for new events",
                        isOn: Binding(
                            get: { viewModel.notificationsEnabled },
                            set: {
                                viewModel.notificationsEnabled = $0
                                viewModel.savePreferences()
                            }
                        )
                    )

                    toggleRow(
                        icon: "exclamationmark.triangle.fill",
                        title: "Critical Alerts",
                        description: "High-priority alerts bypass Do Not Disturb",
                        isOn: Binding(
                            get: { viewModel.criticalAlertsEnabled },
                            set: {
                                viewModel.criticalAlertsEnabled = $0
                                viewModel.savePreferences()
                            }
                        )
                    )
                }

                // Regions section
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    SectionHeader(title: "Monitored Regions")

                    ForEach(viewModel.availableRegions) { region in
                        SelectionCheckbox(
                            title: region.name,
                            isSelected: Binding(
                                get: { viewModel.selectedRegionIDs.contains(region.id) },
                                set: { _ in viewModel.toggleRegion(region.id) }
                            )
                        )
                    }
                }

                // About section
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    SectionHeader(title: "About")

                    infoRow(label: "Version", value: "1.0.0")
                    infoRow(label: "Build", value: "2026.03.15")
                    infoRow(label: "Data Source", value: "ACLED / Firebase")
                }

                // Reset
                Button {
                    viewModel.resetOnboarding()
                } label: {
                    Text("Reset Onboarding")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.danger)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: AppSpacing.minTouchTarget)
                }
                .padding(.top, AppSpacing.md)
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.background)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Components

    private func toggleRow(icon: String, title: String, description: String, isOn: Binding<Bool>) -> some View {
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

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)

            Spacer()

            Text(value)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMedium))
    }
}

#Preview {
    NavigationStack {
        SystemSettingsView()
    }
    .preferredColorScheme(.dark)
}
