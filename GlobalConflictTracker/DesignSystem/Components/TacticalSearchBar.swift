import SwiftUI

/// Glassmorphic search bar with tactical styling
/// Used in: Tactical Map, Factions Directory
struct TacticalSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)

            TextField(placeholder, text: $text)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.textTertiary)
                }
                .frame(minWidth: AppSpacing.minTouchTarget, minHeight: AppSpacing.minTouchTarget)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .frame(height: AppSpacing.minTouchTarget)
        .background(.ultraThinMaterial.opacity(0.5))
        .background(AppColors.surface.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

#Preview("Search Bar") {
    VStack(spacing: 20) {
        TacticalSearchBar(text: .constant(""), placeholder: "Search tactical coordinates...")
        TacticalSearchBar(text: .constant("Red Sea"), placeholder: "Search...")
    }
    .padding()
    .background(AppColors.background)
}
