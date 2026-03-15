import SwiftUI

/// Matches Figma node 1:79 — Intel Feed
struct IntelFeedView: View {
    @State private var viewModel = IntelFeedViewModel(
        eventService: ServiceContainer.shared.eventService
    )

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.sm)

            // Filter tabs
            FilterTabBar(selectedCategory: $viewModel.selectedCategory)
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.md)

            // Content
            if viewModel.isLoading {
                loadingContent
            } else if let error = viewModel.errorMessage, viewModel.reports.isEmpty {
                ErrorStateView(title: "Feed Unavailable", message: error) {
                    Task { await viewModel.loadReports() }
                }
            } else if viewModel.isEmpty {
                EmptyStateView(
                    icon: "doc.text.magnifyingglass",
                    title: "No Intel Reports",
                    message: "No intelligence reports match your current filter. Try selecting a different category.",
                    actionTitle: "Show All"
                ) {
                    viewModel.selectCategory(nil)
                }
            } else {
                feedContent
            }
        }
        .background(AppColors.background)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadReports()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "scope")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppColors.accent)

                Text("INTEL FEED")
                    .font(AppTypography.heading2)
                    .tracking(AppTypography.trackingNormal)
                    .foregroundStyle(AppColors.textPrimary)
            }

            Spacer()

            Button {} label: {
                Image(systemName: "bell.badge")
                    .font(.system(size: 18))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(minWidth: AppSpacing.minTouchTarget, minHeight: AppSpacing.minTouchTarget)
            }

            Button {} label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(minWidth: AppSpacing.minTouchTarget, minHeight: AppSpacing.minTouchTarget)
            }
        }
    }

    // MARK: - Feed Content

    private var feedContent: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.sm) {
                ForEach(viewModel.filteredReports) { report in
                    NavigationLink(value: report) {
                        IntelArticleCard(report: report)
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(TapGesture().onEnded {
                        Task { await viewModel.markAsRead(report) }
                    })
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
        .refreshable {
            await viewModel.loadReports()
        }
    }

    // MARK: - Loading

    private var loadingContent: some View {
        ScrollView {
            VStack(spacing: AppSpacing.sm) {
                ForEach(0..<4, id: \.self) { _ in
                    IntelCardSkeleton()
                }
            }
            .padding(.horizontal, AppSpacing.md)
        }
    }
}

#Preview {
    NavigationStack {
        IntelFeedView()
    }
    .preferredColorScheme(.dark)
}
