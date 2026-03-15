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

                // Dev Tools section
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    SectionHeader(title: "Dev Tools")

                    toggleRow(
                        icon: "server.rack",
                        title: "Use Mock Data",
                        description: "Switch between local mock data and Firebase",
                        isOn: Binding(
                            get: { viewModel.useMockServices },
                            set: { viewModel.useMockServices = $0 }
                        )
                    )

                    // Data source indicator
                    HStack(spacing: AppSpacing.sm) {
                        Circle()
                            .fill(viewModel.useMockServices ? AppColors.warning : AppColors.success)
                            .frame(width: 8, height: 8)

                        Text(viewModel.useMockServices ? "MOCK DATA ACTIVE" : "FIREBASE CONNECTED")
                            .font(AppTypography.labelSmall)
                            .tracking(AppTypography.trackingWide)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.horizontal, AppSpacing.md)

                    // Seed button
                    Button {
                        Task { await viewModel.seedFirestore() }
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            if viewModel.isSeedingInProgress {
                                ProgressView()
                                    .tint(AppColors.textPrimary)
                            } else {
                                Image(systemName: "arrow.up.doc.fill")
                                    .font(.system(size: 16))
                            }
                            Text("Seed Firebase with Sample Data")
                                .font(AppTypography.body)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: AppSpacing.minTouchTarget)
                        .foregroundStyle(AppColors.textPrimary)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMedium))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                    }
                    .disabled(viewModel.isSeedingInProgress)

                    // Seed result feedback
                    if let result = viewModel.seedResult {
                        Text(result)
                            .font(AppTypography.bodySmall)
                            .foregroundStyle(result.contains("failed") ? AppColors.danger : AppColors.success)
                            .padding(.horizontal, AppSpacing.md)
                    }
                }

                // About section
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    SectionHeader(title: "About")

                    infoRow(label: "Version", value: "1.0.0")
                    infoRow(label: "Build", value: "2026.03.15")
                    infoRow(label: "Data Source", value: viewModel.useMockServices ? "Mock (Local)" : "ACLED / Firebase")
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
        .background(AppColors.background.ignoresSafeArea())
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
