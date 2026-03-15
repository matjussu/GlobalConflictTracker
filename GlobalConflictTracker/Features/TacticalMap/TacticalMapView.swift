import SwiftUI
import MapKit

/// Matches Figma nodes 1:2 (Tactical Map) and 1:440 (Main Map Viewport)
struct TacticalMapView: View {
    @State private var viewModel = TacticalMapViewModel(
        eventService: MockEventService()
    )

    var body: some View {
        ZStack {
            // Map
            mapContent

            // Overlays
            VStack(spacing: 0) {
                headerOverlay
                Spacer()
            }

            // Error state
            if let error = viewModel.errorMessage, viewModel.events.isEmpty {
                ErrorStateView(
                    title: "Connection Lost",
                    message: error
                ) {
                    Task { await viewModel.loadEvents() }
                }
            }

            // Bottom sheet alert
            FloatingBottomSheet(isPresented: $viewModel.showAlert) {
                if let event = viewModel.selectedEvent ?? viewModel.latestCriticalEvent {
                    alertSheetContent(event: event)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadEvents()
        }
    }

    // MARK: - Map

    private var mapContent: some View {
        Map(position: $viewModel.cameraPosition) {
            ForEach(viewModel.filteredEvents) { event in
                Annotation(
                    event.title,
                    coordinate: event.coordinate,
                    anchor: .center
                ) {
                    Button {
                        viewModel.selectEvent(event)
                    } label: {
                        ConflictAnnotation(event: event)
                    }
                }
            }
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
        .mapControlVisibility(.hidden)
        .ignoresSafeArea()
    }

    // MARK: - Header Overlay

    private var headerOverlay: some View {
        VStack(spacing: AppSpacing.sm) {
            // Top bar
            HStack {
                // Live OPS badge
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.accent)

                    Text("LIVE OPS")
                        .font(AppTypography.labelSmall)
                        .tracking(AppTypography.trackingWide)
                        .foregroundStyle(AppColors.textPrimary)
                }
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs + 2)
                .background(.ultraThinMaterial.opacity(0.8))
                .background(AppColors.surface.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMedium))
                .overlay(
                    RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                        .stroke(AppColors.border, lineWidth: 1)
                )

                Spacer()

                // Map layers button
                Button {
                    // Map options
                } label: {
                    Image(systemName: "square.3.layers.3d")
                        .font(.system(size: 18))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: AppSpacing.minTouchTarget, height: AppSpacing.minTouchTarget)
                        .background(.ultraThinMaterial.opacity(0.8))
                        .background(AppColors.surface.opacity(0.7))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, AppSpacing.md)

            // Search bar
            TacticalSearchBar(
                text: $viewModel.searchText,
                placeholder: "Search tactical coordinates..."
            )
            .padding(.horizontal, AppSpacing.md)
        }
        .padding(.top, AppSpacing.md)
    }

    // MARK: - Alert Sheet Content

    private func alertSheetContent(event: ConflictEvent) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                SeverityBadge(severity: event.severity)

                Text("IMMEDIATE ALERT")
                    .font(AppTypography.caption)
                    .tracking(AppTypography.trackingWide)
                    .foregroundStyle(AppColors.accent)
            }

            Text(event.title)
                .font(AppTypography.heading1)
                .foregroundStyle(AppColors.textPrimary)

            Text(event.summary)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .lineSpacing(3)

            NavigationLink(value: event) {
                HStack {
                    Spacer()
                    Text("View Full Intel Report")
                        .font(AppTypography.heading3)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                }
                .frame(minHeight: AppSpacing.minTouchTarget)
                .foregroundStyle(AppColors.textPrimary)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMedium))
                .overlay(
                    RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                        .stroke(AppColors.border, lineWidth: 1)
                )
            }
        }
        .padding(AppSpacing.md)
        .padding(.bottom, AppSpacing.md)
    }
}

#Preview {
    NavigationStack {
        TacticalMapView()
    }
    .preferredColorScheme(.dark)
}
