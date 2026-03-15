import SwiftUI

/// Intel article card with severity badge, timestamp, headline, image
/// Supports read/unread visual state
/// Used in: Intel Feed (inside NavigationLink — NOT a Button itself to avoid nested interactives)
struct IntelArticleCard: View {
    let report: IntelReport

    private var relativeTime: String {
        RelativeTimeFormatter.string(from: report.timestamp)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Top row: badge + metadata
            HStack(spacing: AppSpacing.sm) {
                SeverityBadge(severity: report.severity)

                Text("\(relativeTime) • \(report.sector)")
                    .font(AppTypography.caption)
                    .tracking(AppTypography.trackingNormal)
                    .foregroundStyle(AppColors.textSecondary)
                    .textCase(.uppercase)

                Spacer()
            }

            // Headline
            Text(report.headline)
                .font(AppTypography.heading2)
                .foregroundStyle(report.isRead ? AppColors.textSecondary : AppColors.textPrimary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            // Body preview
            if !report.body.isEmpty {
                Text(report.body)
                    .font(AppTypography.bodySmall)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }

            // View data link
            HStack(spacing: AppSpacing.xs) {
                Text("VIEW DATA")
                    .font(AppTypography.caption)
                    .tracking(AppTypography.trackingWide)
                Image(systemName: "arrow.right")
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundStyle(AppColors.accent)
            .padding(.top, AppSpacing.xs)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .opacity(report.isRead ? 0.7 : 1.0)
        .accessibilityLabel("\(report.severity.label) alert: \(report.headline)")
        .accessibilityHint("Double tap to view full intel report")
    }
}

#Preview("Intel Cards") {
    ScrollView {
        VStack(spacing: 12) {
            IntelArticleCard(report: SampleData.intelReports[0])
            IntelArticleCard(report: SampleData.intelReports[1])
            IntelArticleCard(report: SampleData.intelReports[3])
        }
        .padding()
    }
    .background(AppColors.background)
    .preferredColorScheme(.dark)
}
