import SwiftUI

/// Cluster annotation view for dense map areas
/// Shows count of events in a cluster
/// Used in: Tactical Map
struct ClusterMarkerView: View {
    let count: Int
    var maxSeverity: Severity = .low

    private var size: CGFloat {
        switch count {
        case 1...5: 36
        case 6...15: 44
        default: 52
        }
    }

    var body: some View {
        ZStack {
            // Outer pulse ring
            Circle()
                .fill(AppColors.severityColor(maxSeverity).opacity(0.15))
                .frame(width: size + 12, height: size + 12)

            // Inner circle
            Circle()
                .fill(AppColors.severityColor(maxSeverity).opacity(0.3))
                .frame(width: size, height: size)

            // Core
            Circle()
                .fill(AppColors.severityColor(maxSeverity))
                .frame(width: size - 8, height: size - 8)

            Text("\(count)")
                .font(AppTypography.labelSmall)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        .accessibilityLabel("\(count) events in this area")
    }
}

#Preview("Cluster Markers") {
    HStack(spacing: 30) {
        ClusterMarkerView(count: 3, maxSeverity: .low)
        ClusterMarkerView(count: 8, maxSeverity: .warning)
        ClusterMarkerView(count: 23, maxSeverity: .critical)
    }
    .padding()
    .background(AppColors.background)
    .preferredColorScheme(.dark)
}
