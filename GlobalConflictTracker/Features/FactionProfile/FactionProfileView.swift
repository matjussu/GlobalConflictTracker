import SwiftUI

/// Matches Figma node 1:599 — Faction Profile
struct FactionProfileView: View {
    @State private var viewModel: FactionProfileViewModel

    init(faction: Faction) {
        _viewModel = State(initialValue: FactionProfileViewModel(
            faction: faction,
            eventService: ServiceContainer.shared.eventService
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // Header
                profileHeader

                // Stats cards
                statsSection

                // Deployment Zones
                deploymentSection

                // Recent Events
                if !viewModel.recentEvents.isEmpty {
                    recentEventsSection
                }
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text("FACTION PROFILE")
                        .font(AppTypography.labelSmall)
                        .tracking(AppTypography.trackingWide)
                        .foregroundStyle(AppColors.textSecondary)

                    Text("TACTICAL OVERVIEW")
                        .font(AppTypography.labelSmall)
                        .tracking(AppTypography.trackingNormal)
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
        }
        .task {
            await viewModel.loadRecentEvents()
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Type badge
            Text(viewModel.faction.type.label.uppercased())
                .font(AppTypography.labelSmall)
                .tracking(AppTypography.trackingWide)
                .foregroundStyle(.white)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(AppColors.accent)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusSmall))

            // Name
            Text(viewModel.faction.name)
                .font(AppTypography.displayMedium)
                .foregroundStyle(AppColors.textPrimary)

            // ID + Status
            HStack(spacing: AppSpacing.sm) {
                Text("ID: \(viewModel.faction.id.uppercased())")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)

                StatusIndicator(status: viewModel.faction.status)
            }
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(spacing: AppSpacing.sm) {
            StatCard(
                label: "Personnel",
                value: viewModel.faction.formattedPersonnel,
                trend: viewModel.faction.personnelTrend,
                icon: "person.2.fill"
            )

            StatCard(
                label: "Fleet Strength",
                value: viewModel.faction.formattedFleet,
                trend: viewModel.faction.fleetTrend,
                icon: "shield.fill"
            )

            StatCard(
                label: "Air Assets",
                value: viewModel.faction.formattedAir,
                trend: viewModel.faction.airTrend,
                icon: "airplane"
            )
        }
    }

    // MARK: - Deployment Zones

    private var deploymentSection: some View {
        VStack(spacing: AppSpacing.sm) {
            SectionHeader(title: "Active Deployment Zones", action: {}, actionLabel: "EXPAND VIEW")

            ForEach(viewModel.faction.deploymentZones, id: \.self) { zone in
                DeploymentZoneCard(zoneName: zone)
            }
        }
    }

    // MARK: - Recent Events

    private var recentEventsSection: some View {
        VStack(spacing: AppSpacing.sm) {
            SectionHeader(title: "Recent Events")

            ForEach(viewModel.recentEvents) { event in
                NavigationLink(value: event) {
                    HStack(spacing: AppSpacing.md) {
                        EventTypeIcon(eventType: event.eventType, size: 18)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.title)
                                .font(AppTypography.bodySmall)
                                .foregroundStyle(AppColors.textPrimary)
                                .lineLimit(1)

                            Text(RelativeTimeFormatter.string(from: event.timestamp))
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textTertiary)
                        }

                        Spacer()

                        SeverityBadge(severity: event.severity)
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMedium))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack {
        FactionProfileView(faction: SampleData.factions[0])
    }
    .preferredColorScheme(.dark)
}
