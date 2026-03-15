import SwiftUI

/// Uppercase tracking section header
/// e.g. "GLOBAL DIRECTORY", "OPERATIONAL REGIONS"
/// Used in: All list screens
struct SectionHeader: View {
    let title: String
    var action: (() -> Void)?
    var actionLabel: String?

    var body: some View {
        HStack {
            Text(title)
                .sectionHeaderStyle()

            Spacer()

            if let actionLabel, let action {
                Button(action: action) {
                    Text(actionLabel)
                        .font(AppTypography.caption)
                        .tracking(AppTypography.trackingNormal)
                        .foregroundStyle(AppColors.accent)
                }
                .frame(minHeight: AppSpacing.minTouchTarget)
            }
        }
    }
}

#Preview("Section Headers") {
    VStack(alignment: .leading, spacing: 24) {
        SectionHeader(title: "Global Directory")
        SectionHeader(title: "Active Deployment Zones", action: {}, actionLabel: "EXPAND VIEW")
        SectionHeader(title: "Operational Regions")
    }
    .padding()
    .background(AppColors.background)
    .preferredColorScheme(.dark)
}
