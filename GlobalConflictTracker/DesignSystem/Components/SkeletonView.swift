import SwiftUI

/// Animated loading skeleton placeholder
/// Used in: All list views during data loading
struct SkeletonView: View {
    var width: CGFloat? = nil
    var height: CGFloat = 16

    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: AppSpacing.radiusSmall)
            .fill(
                LinearGradient(
                    colors: [
                        AppColors.surface,
                        AppColors.surfaceElevated,
                        AppColors.surface,
                    ],
                    startPoint: isAnimating ? .leading : .trailing,
                    endPoint: isAnimating ? .trailing : .leading
                )
            )
            .frame(width: width, height: height)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
    }
}

/// Pre-built skeleton for an Intel article card
struct IntelCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                SkeletonView(width: 70, height: 20)
                SkeletonView(width: 120, height: 14)
                Spacer()
            }
            SkeletonView(height: 20)
            SkeletonView(width: 250, height: 20)
            SkeletonView(height: 14)
            SkeletonView(width: 80, height: 14)
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLarge))
    }
}

/// Pre-built skeleton for a Faction row
struct FactionRowSkeleton: View {
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            SkeletonView(width: 44, height: 44)
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                SkeletonView(width: 150, height: 16)
                SkeletonView(width: 100, height: 12)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                SkeletonView(width: 70, height: 18)
                SkeletonView(width: 60, height: 10)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLarge))
    }
}

#Preview("Skeletons") {
    VStack(spacing: 12) {
        IntelCardSkeleton()
        IntelCardSkeleton()
        FactionRowSkeleton()
        FactionRowSkeleton()
    }
    .padding()
    .background(AppColors.background)
    .preferredColorScheme(.dark)
}
