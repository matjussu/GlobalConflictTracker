import SwiftUI

/// Faction list row — emblem + name + status + personnel count
/// Used in: Factions Directory
struct FactionRow: View {
    let faction: Faction
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Emblem placeholder
            ZStack {
                RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                    .fill(AppColors.surfaceElevated)
                    .frame(width: 44, height: 44)

                Image(systemName: faction.type.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(isSelected ? AppColors.accent : AppColors.textSecondary)
            }

            // Name + Status
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(faction.name)
                    .font(AppTypography.heading3)
                    .foregroundStyle(AppColors.textPrimary)

                StatusIndicator(status: faction.status)
            }

            Spacer()

            // Personnel count
            VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                Text(formatCount(faction.personnelCount))
                    .font(AppTypography.heading2)
                    .foregroundStyle(AppColors.textPrimary)
                    .fontDesign(.default)

                Text("PERSONNEL")
                    .font(AppTypography.labelSmall)
                    .tracking(AppTypography.trackingWide)
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                .stroke(isSelected ? AppColors.borderActive : AppColors.border, lineWidth: isSelected ? 1.5 : 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(faction.name), \(faction.status.label), \(formatCount(faction.personnelCount)) personnel")
    }

    private func formatCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return "\(count / 1_000),\(String(format: "%03d", count % 1_000))"
        }
        return "\(count)"
    }
}

#Preview("Faction Rows") {
    VStack(spacing: 8) {
        FactionRow(faction: SampleData.factions[0], isSelected: true)
        FactionRow(faction: SampleData.factions[1])
        FactionRow(faction: SampleData.factions[2])
    }
    .padding()
    .background(AppColors.background)
    .preferredColorScheme(.dark)
}
