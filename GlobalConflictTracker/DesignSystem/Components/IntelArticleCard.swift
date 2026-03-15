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
            // Top row: badge + reliability + metadata
            HStack(spacing: AppSpacing.sm) {
                SeverityBadge(severity: report.severity)

                HStack(spacing: 4) {
                    Circle()
                        .fill(report.sourceReliability.color)
                        .frame(width: 6, height: 6)
                    Text(report.sourceReliability.label.uppercased())
                        .font(AppTypography.labelSmall)
                        .tracking(AppTypography.trackingWide)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Text("\(relativeTime) • \(report.sector)")
                    .font(AppTypography.caption)
                    .tracking(AppTypography.trackingNormal)
                    .foregroundStyle(AppColors.textSecondary)
                    .textCase(.uppercase)
                    .lineLimit(1)

                Spacer()
            }

            // Headline
            Text(report.headline)
                .font(AppTypography.heading3)
                .foregroundStyle(report.isRead ? AppColors.textSecondary : AppColors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // Image thumbnail
            if let imageURL = report.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(AppColors.background)
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMedium))
            }

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
                    .font(AppTypography.labelLarge)
                    .tracking(AppTypography.trackingWide)
                Image(systemName: "chevron.right")
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
