import SwiftUI

/// Error state with retry button
/// Used in: All screens when network/data fetch fails
struct ErrorStateView: View {
    let title: String
    let message: String
    var retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()

            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(AppColors.warning)
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

            if let retryAction {
                TacticalButton(title: "Retry", icon: "arrow.clockwise", style: .secondary, action: retryAction)
                    .frame(maxWidth: 200)
                    .padding(.top, AppSpacing.sm)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
    }
}

#Preview("Error States") {
    VStack {
        ErrorStateView(
            title: "Connection Lost",
            message: "Unable to reach tactical servers. Check your network connection and try again."
        ) {}
    }
    .background(AppColors.background)
    .preferredColorScheme(.dark)
}
