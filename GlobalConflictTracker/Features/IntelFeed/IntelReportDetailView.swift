import SwiftUI

/// Detail view for an Intel Report
/// Shows full report content and optionally loads the related event
struct IntelReportDetailView: View {
    @State private var viewModel: IntelReportDetailViewModel

    init(report: IntelReport) {
        _viewModel = State(initialValue: IntelReportDetailViewModel(report: report))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // Header: severity + metadata
                reportHeader

                // Headline
                Text(viewModel.report.headline)
                    .font(AppTypography.heading1)
                    .foregroundStyle(AppColors.textPrimary)

                // Image
                if let imageURL = viewModel.report.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(AppColors.surface)
                            .overlay {
                                ProgressView()
                                    .tint(AppColors.textSecondary)
                            }
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLarge))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
                }

                // Body
                Text(viewModel.report.body)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(4)

                // Key Points
                keyPointsSection

                // Tactical Analysis
                tacticalAnalysisSection

                // Source link
                sourceLinkSection

                // Metadata section
                metadataSection

                // Related event
                relatedEventSection
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("INTEL REPORT")
                    .font(AppTypography.labelLarge)
                    .tracking(AppTypography.trackingWide)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .task {
            await viewModel.loadRelatedEvent()
        }
    }

    // MARK: - Header

    private var reportHeader: some View {
        HStack(spacing: AppSpacing.sm) {
            SeverityBadge(severity: viewModel.report.severity)

            Text(viewModel.report.sector.uppercased())
                .font(AppTypography.caption)
                .tracking(AppTypography.trackingNormal)
                .foregroundStyle(AppColors.textSecondary)

            Spacer()

            Text(RelativeTimeFormatter.string(from: viewModel.report.timestamp))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    // MARK: - Metadata

    private var metadataSection: some View {
        VStack(spacing: AppSpacing.sm) {
            SectionHeader(title: "Intelligence Data")

            VStack(spacing: 1) {
                metadataRow(label: "Sector", value: viewModel.report.sector)
                metadataRow(label: "Category", value: viewModel.report.category.label)
                metadataRow(
                    label: "Timestamp",
                    value: viewModel.report.timestamp.formatted(.dateTime.month().day().hour().minute()) + " UTC"
                )

                HStack {
                    Text("SOURCE RELIABILITY")
                        .font(AppTypography.caption)
                        .tracking(AppTypography.trackingWide)
                        .foregroundStyle(AppColors.textSecondary)

                    Spacer()

                    HStack(spacing: AppSpacing.xs) {
                        Circle()
                            .fill(viewModel.report.sourceReliability.color)
                            .frame(width: 8, height: 8)

                        Text("\(viewModel.report.sourceReliability.label) (\(viewModel.report.sourceReliability.score)/10)")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                }
                .padding(AppSpacing.md)
                .background(AppColors.surface)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLarge))
        }
    }

    private func metadataRow(label: String, value: String) -> some View {
        HStack {
            Text(label.uppercased())
                .font(AppTypography.caption)
                .tracking(AppTypography.trackingWide)
                .foregroundStyle(AppColors.textSecondary)

            Spacer()

            Text(value)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
    }

    // MARK: - Key Points

    @ViewBuilder
    private var keyPointsSection: some View {
        if let keyPoints = viewModel.report.keyPoints, !keyPoints.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                SectionHeader(title: "Key Points")

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    ForEach(keyPoints, id: \.self) { point in
                        HStack(alignment: .top, spacing: AppSpacing.sm) {
                            Circle()
                                .fill(AppColors.accent)
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)

                            Text(point)
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.textPrimary)
                                .lineSpacing(3)
                        }
                    }
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLarge))
                .overlay(
                    RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                        .stroke(AppColors.border, lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Tactical Analysis

    @ViewBuilder
    private var tacticalAnalysisSection: some View {
        if let summary = viewModel.report.contentSummary, !summary.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                SectionHeader(title: "Tactical Analysis")

                Text(summary)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(4)
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLarge))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
            }
        }
    }

    // MARK: - Source Link

    @ViewBuilder
    private var sourceLinkSection: some View {
        if let sourceURL = viewModel.report.sourceURL, let url = URL(string: sourceURL) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                SectionHeader(title: "Source")

                Link(destination: url) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "link")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppColors.accent)

                        Text(url.host ?? sourceURL)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.accent)
                            .lineLimit(1)

                        Spacer()

                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColors.textSecondary)
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
        }
    }

    // MARK: - Related Event

    @ViewBuilder
    private var relatedEventSection: some View {
        if viewModel.report.relatedEventID != nil {
            VStack(spacing: AppSpacing.sm) {
                SectionHeader(title: "Related Event")

                if viewModel.isLoadingEvent {
                    HStack {
                        ProgressView()
                            .tint(AppColors.textSecondary)
                        Text("Loading event…")
                            .font(AppTypography.bodySmall)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(AppSpacing.md)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLarge))
                } else if let event = viewModel.relatedEvent {
                    NavigationLink(value: event) {
                        HStack(spacing: AppSpacing.sm) {
                            EventTypeIcon(eventType: event.eventType, size: 18)

                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text(event.title)
                                    .font(AppTypography.heading3)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)

                                Text(RelativeTimeFormatter.string(from: event.timestamp))
                                    .font(AppTypography.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .padding(AppSpacing.md)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLarge))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        IntelReportDetailView(report: SampleData.intelReports[0])
    }
    .preferredColorScheme(.dark)
}
