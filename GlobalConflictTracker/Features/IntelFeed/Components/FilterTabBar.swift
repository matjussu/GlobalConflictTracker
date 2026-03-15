import SwiftUI

/// Horizontal filter tabs: CHRONOLOGICAL / HIGH ALERT / GLOBAL
/// Matches Figma node 1:79 header tabs
struct FilterTabBar: View {
    @Binding var selectedCategory: IntelCategory?

    private var tabs: [(IntelCategory?, String)] {
        [
            (nil, "ALL"),
            (.chronological, "CHRONOLOGICAL"),
            (.highAlert, "HIGH ALERT"),
            (.global, "GLOBAL"),
        ]
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.lg) {
                ForEach(tabs, id: \.1) { category, label in
                    tabButton(label: label, category: category)
                }
            }
        }
    }

    private func tabButton(label: String, category: IntelCategory?) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
            HapticManager.selection()
        } label: {
            VStack(spacing: AppSpacing.xs) {
                Text(label)
                    .font(AppTypography.labelLarge)
                    .tracking(AppTypography.trackingWide)
                    .foregroundStyle(isSelected(category) ? AppColors.textPrimary : AppColors.textTertiary)

                Rectangle()
                    .fill(isSelected(category) ? AppColors.accent : .clear)
                    .frame(height: 2)
            }
        }
        .frame(minHeight: AppSpacing.minTouchTarget)
        .accessibilityAddTraits(isSelected(category) ? [.isSelected] : [])
    }

    private func isSelected(_ category: IntelCategory?) -> Bool {
        selectedCategory == category
    }
}

#Preview {
    VStack {
        FilterTabBar(selectedCategory: .constant(nil))
        FilterTabBar(selectedCategory: .constant(.highAlert))
    }
    .padding()
    .background(AppColors.background)
    .preferredColorScheme(.dark)
}
