import SwiftUI

/// Matches Figma node 1:198 — Factions Directory
struct FactionsDirectoryView: View {
    @State private var viewModel = FactionsDirectoryViewModel(
        factionService: MockFactionService()
    )

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Factions")
                    .font(AppTypography.displayMedium)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Button {
                    viewModel.showFilterSheet = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 18))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(minWidth: AppSpacing.minTouchTarget, minHeight: AppSpacing.minTouchTarget)
                }
            }
            .padding(.horizontal, AppSpacing.md)

            // Search
            TacticalSearchBar(
                text: $viewModel.searchText,
                placeholder: "Search global military forces..."
            )
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)

            // Content
            if viewModel.isLoading {
                loadingContent
            } else if let error = viewModel.errorMessage, viewModel.factions.isEmpty {
                ErrorStateView(title: "Data Unavailable", message: error) {
                    Task { await viewModel.loadFactions() }
                }
            } else if viewModel.isEmpty {
                EmptyStateView(
                    icon: "person.3",
                    title: "No Factions Found",
                    message: "No factions match your search criteria.",
                    actionTitle: "Reset"
                ) {
                    viewModel.resetFilters()
                }
            } else {
                factionsList
            }
        }
        .background(AppColors.background)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $viewModel.showFilterSheet) {
            FactionFilterSheet(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .task {
            await viewModel.loadFactions()
        }
    }

    // MARK: - Factions List

    private var factionsList: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.sm) {
                SectionHeader(title: "Global Directory")
                    .padding(.horizontal, AppSpacing.md)

                ForEach(viewModel.filteredFactions) { faction in
                    NavigationLink(value: faction) {
                        FactionRow(
                            faction: faction,
                            isSelected: viewModel.selectedFactionID == faction.id
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AppSpacing.md)
                }

                // Sector Summary Card
                SectorSummaryCard(factionCount: viewModel.factions.count)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.md)
            }
            .padding(.bottom, AppSpacing.xl)
        }
        .refreshable {
            await viewModel.loadFactions()
        }
    }

    // MARK: - Loading

    private var loadingContent: some View {
        ScrollView {
            VStack(spacing: AppSpacing.sm) {
                ForEach(0..<5, id: \.self) { _ in
                    FactionRowSkeleton()
                }
            }
            .padding(.horizontal, AppSpacing.md)
        }
    }
}

#Preview {
    NavigationStack {
        FactionsDirectoryView()
    }
    .preferredColorScheme(.dark)
}
