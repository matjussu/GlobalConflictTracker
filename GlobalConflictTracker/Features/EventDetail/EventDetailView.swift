import SwiftUI
import MapKit

/// Matches Figma node 1:527 — Event Intelligence Detail
struct EventDetailView: View {
    @State private var viewModel: EventDetailViewModel

    init(event: ConflictEvent) {
        _viewModel = State(initialValue: EventDetailViewModel(
            event: event,
            eventService: ServiceContainer.shared.eventService,
            factionService: ServiceContainer.shared.factionService
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // Mini map
                miniMap

                // Event header
                eventHeader

                // Summary
                Text(viewModel.event.summary)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(4)

                // Metadata
                metadataSection

                // Tags
                tagsSection

                // Related Factions
                if !viewModel.relatedFactions.isEmpty {
                    relatedFactionsSection
                }
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.background)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("EVENT DETAIL")
                    .font(AppTypography.labelLarge)
                    .tracking(AppTypography.trackingWide)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .task {
            await viewModel.loadRelatedFactions()
        }
    }

    // MARK: - Mini Map

    private var miniMap: some View {
        Map {
            Annotation(
                viewModel.event.title,
                coordinate: viewModel.event.coordinate,
                anchor: .center
            ) {
                ConflictAnnotation(event: viewModel.event)
            }
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .disabled(true)
    }

    // MARK: - Event Header

    private var eventHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                SeverityBadge(severity: viewModel.event.severity)
                EventTypeIcon(eventType: viewModel.event.eventType, size: 18)

                Text(RelativeTimeFormatter.string(from: viewModel.event.timestamp))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Text(viewModel.event.title)
                .font(AppTypography.heading1)
                .foregroundStyle(AppColors.textPrimary)
        }
    }

    // MARK: - Metadata

    private var metadataSection: some View {
        VStack(spacing: AppSpacing.sm) {
            SectionHeader(title: "Intelligence Data")

            VStack(spacing: 1) {
                metadataRow(label: "Event Type", value: viewModel.event.eventType.rawValue.capitalized)
                metadataRow(label: "Coordinates", value: String(format: "%.4f, %.4f", viewModel.event.latitude, viewModel.event.longitude))
                metadataRow(label: "Timestamp", value: viewModel.event.timestamp.formatted(.dateTime.month().day().hour().minute()) + " UTC")

                HStack {
                    Text("SOURCE RELIABILITY")
                        .font(AppTypography.caption)
                        .tracking(AppTypography.trackingWide)
                        .foregroundStyle(AppColors.textSecondary)

                    Spacer()

                    HStack(spacing: AppSpacing.xs) {
                        Circle()
                            .fill(viewModel.event.sourceReliability.color)
                            .frame(width: 8, height: 8)

                        Text("\(viewModel.event.sourceReliability.label) (\(viewModel.event.sourceReliability.score)/10)")
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

    // MARK: - Tags

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Tags")

            FlowLayout(spacing: AppSpacing.sm) {
                ForEach(viewModel.event.tags, id: \.self) { tag in
                    Text(tag.uppercased())
                        .font(AppTypography.labelSmall)
                        .tracking(AppTypography.trackingWide)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusSmall))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppSpacing.radiusSmall)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                }
            }
        }
    }

    // MARK: - Related Factions

    private var relatedFactionsSection: some View {
        VStack(spacing: AppSpacing.sm) {
            SectionHeader(title: "Involved Factions")

            ForEach(viewModel.relatedFactions) { faction in
                NavigationLink(value: faction) {
                    FactionRow(faction: faction)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Flow Layout for tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: currentY + lineHeight), positions)
    }
}

#Preview {
    NavigationStack {
        EventDetailView(event: SampleData.events[0])
    }
    .preferredColorScheme(.dark)
}
