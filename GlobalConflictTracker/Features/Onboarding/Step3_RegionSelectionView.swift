import SwiftUI

/// Matches Figma node 1:343 — Onboarding Step 3
struct Step3_RegionSelectionView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Spacer(minLength: AppSpacing.xxl)

                Text("Select Areas\nof Interest")
                    .font(AppTypography.displayMedium)
                    .foregroundStyle(AppColors.textPrimary)

                Text("Customize your tactical intelligence feed by selecting operational regions and global entities.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(4)

                // Operational Regions
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.accent)

                        SectionHeader(title: "Operational Regions")
                    }

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

                Spacer(minLength: AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.md)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    Step3_RegionSelectionView(viewModel: OnboardingViewModel())
        .background(AppColors.background)
        .preferredColorScheme(.dark)
}
