import SwiftUI

/// Animated concentric ripple effect rendered at impact/destination points.
struct ImpactMarkerView: View {
    let color: Color
    let size: CGFloat

    @State private var animationPhase: Double = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.03)) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 2.0) / 2.0

            ZStack {
                // Outer ripple ring
                Circle()
                    .stroke(color.opacity(0.15 * (1.0 - phase)), lineWidth: 1.5)
                    .frame(width: size * (1.0 + phase * 1.5), height: size * (1.0 + phase * 1.5))

                // Middle ripple ring
                Circle()
                    .stroke(color.opacity(0.25 * (1.0 - phase)), lineWidth: 2)
                    .frame(
                        width: size * (1.0 + phase * 0.8),
                        height: size * (1.0 + phase * 0.8)
                    )

                // Inner glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.6), color.opacity(0.0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.5
                        )
                    )
                    .frame(width: size, height: size)

                // Core dot
                Circle()
                    .fill(color)
                    .frame(width: size * 0.3, height: size * 0.3)
                    .shadow(color: color.opacity(0.8), radius: 4)
            }
        }
        .allowsHitTesting(false)
    }
}
