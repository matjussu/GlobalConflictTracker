import SwiftUI

/// Primary (red fill) and Secondary (outline) tactical buttons
/// Minimum 44pt touch target
/// Used in: Onboarding, Map alerts, Detail views
struct TacticalButton: View {
    let title: String
    var icon: String?
    var style: Style = .primary
    let action: () -> Void

    enum Style {
        case primary
        case secondary
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                Text(title)
                    .font(AppTypography.heading3)
                    .tracking(AppTypography.trackingNormal)

                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: AppSpacing.minTouchTarget)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                    .stroke(borderColor, lineWidth: style == .secondary ? 1.5 : 0)
            )
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: .white
        case .secondary: AppColors.textPrimary
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: AppColors.accent
        case .secondary: .clear
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary: .clear
        case .secondary: AppColors.border
        }
    }
}

#Preview("Buttons") {
    VStack(spacing: 16) {
        TacticalButton(title: "INITIALIZE FEED", icon: "arrow.right", style: .primary) {}
        TacticalButton(title: "View Full Intel Report", icon: "arrow.right", style: .secondary) {}
        TacticalButton(title: "Skip", style: .secondary) {}
    }
    .padding()
    .background(AppColors.background)
    .preferredColorScheme(.dark)
}
