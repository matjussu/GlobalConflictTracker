import SwiftUI

/// Empty state with icon, message, and optional action
/// Used in: Intel Feed, Factions Directory, Map when no events
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(AppColors.textTertiary)
                .padding(.bottom, AppSpacing.sm)

            Text(title)
                .font(AppTypography.heading2)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            if let actionTitle, let action {
                TacticalButton(title: actionTitle, style: .secondary, action: action)
                    .frame(maxWidth: 200)
                    .padding(.top, AppSpacing.sm)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
    }
}

#Preview("Empty States") {
    VStack {
        EmptyStateView(
            icon: "doc.text.magnifyingglass",
            title: "No Intel Reports",
            message: "No intelligence reports match your current filters. Try adjusting your criteria.",
            actionTitle: "Reset Filters"
        ) {}
    }
    .background(AppColors.background)
    .preferredColorScheme(.dark)
}
