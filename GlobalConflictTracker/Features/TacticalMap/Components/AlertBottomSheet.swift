import SwiftUI

/// Dedicated alert bottom sheet for critical events
/// Wraps FloatingBottomSheet with event-specific content
struct AlertBottomSheet: View {
    let event: ConflictEvent
    @Binding var isPresented: Bool
    var onViewDetail: () -> Void = {}

    var body: some View {
        FloatingBottomSheet(isPresented: $isPresented) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(spacing: AppSpacing.sm) {
                    SeverityBadge(severity: event.severity)

                    Text("IMMEDIATE ALERT")
                        .font(AppTypography.caption)
                        .tracking(AppTypography.trackingWide)
                        .foregroundStyle(AppColors.accent)

                    Spacer()

                    EventTypeIcon(eventType: event.eventType, size: 20)
                }

                Text(event.title)
                    .font(AppTypography.heading1)
                    .foregroundStyle(AppColors.textPrimary)

                Text(event.summary)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(3)

                // Source reliability
                HStack(spacing: AppSpacing.xs) {
                    Circle()
                        .fill(event.sourceReliability.color)
                        .frame(width: 8, height: 8)

                    Text("Source: \(event.sourceReliability.label) (\(event.sourceReliability.score)/10)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.top, AppSpacing.xs)

                TacticalButton(title: "View Full Intel Report", icon: "arrow.right", style: .secondary) {
                    onViewDetail()
                }
                .padding(.top, AppSpacing.sm)
            }
            .padding(AppSpacing.md)
            .padding(.bottom, AppSpacing.md)
        }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        AlertBottomSheet(
            event: SampleData.events[0],
            isPresented: .constant(true)
        )
    }
    .preferredColorScheme(.dark)
}
