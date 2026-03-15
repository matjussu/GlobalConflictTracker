import SwiftUI

/// Filter/sort sheet for Factions Directory
struct FactionFilterSheet: View {
    @Bindable var viewModel: FactionsDirectoryViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Sort section
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    SectionHeader(title: "Sort By")

                    ForEach(FactionsDirectoryViewModel.SortOption.allCases, id: \.self) { option in
                        Button {
                            viewModel.sortBy = option
                            HapticManager.selection()
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.textPrimary)

                                Spacer()

                                if viewModel.sortBy == option {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(AppColors.accent)
                                }
                            }
                            .padding(AppSpacing.md)
                            .background(viewModel.sortBy == option ? AppColors.surface : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMedium))
                        }
                        .frame(minHeight: AppSpacing.minTouchTarget)
                    }
                }

                // Filter by type
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    SectionHeader(title: "Filter by Type")

                    HStack(spacing: AppSpacing.sm) {
                        filterChip(label: "All", isSelected: viewModel.filterByType == nil) {
                            viewModel.filterByType = nil
                        }

                        ForEach(FactionType.allCases, id: \.self) { type in
                            filterChip(label: type.label, isSelected: viewModel.filterByType == type) {
                                viewModel.filterByType = type
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(AppSpacing.md)
            .background(AppColors.background)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(AppColors.accent)
                }
            }
        }
    }

    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(AppTypography.bodySmall)
                .foregroundStyle(isSelected ? .white : AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(isSelected ? AppColors.accent : AppColors.surface)
                .clipShape(Capsule())
        }
        .frame(minHeight: AppSpacing.minTouchTarget)
    }
}

#Preview {
    FactionFilterSheet(viewModel: FactionsDirectoryViewModel(factionService: MockFactionService()))
        .preferredColorScheme(.dark)
}
