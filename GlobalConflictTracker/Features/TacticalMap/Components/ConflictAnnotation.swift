import SwiftUI

/// Custom map annotation marker differentiated by event type
/// Replaces generic red circles with typed icons
struct ConflictAnnotation: View {
    let event: ConflictEvent

    @State private var isPulsing = false

    private var size: CGFloat {
        event.severity == .critical ? 32 : 24
    }

    var body: some View {
        ZStack {
            // Outer pulse ring for critical events
            if event.severity == .critical {
                Circle()
                    .fill(AppColors.accent.opacity(0.2))
                    .frame(width: size + 16, height: size + 16)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .opacity(isPulsing ? 0 : 0.6)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                        value: isPulsing
                    )
            }

            // Severity ring
            Circle()
                .fill(AppColors.severityColor(event.severity).opacity(0.3))
                .frame(width: size + 8, height: size + 8)

            // Core marker
            Circle()
                .fill(AppColors.severityColor(event.severity))
                .frame(width: size, height: size)

            // Type icon
            Image(systemName: event.eventType.icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(.white)
        }
        .onAppear {
            if event.severity == .critical {
                isPulsing = true
            }
        }
        .accessibilityLabel("\(event.severity.label) \(event.eventType.accessibilityLabel): \(event.title)")
    }
}

#Preview("Annotations") {
    HStack(spacing: 30) {
        ForEach(SampleData.events) { event in
            ConflictAnnotation(event: event)
        }
    }
    .padding(40)
    .background(AppColors.background)
    .preferredColorScheme(.dark)
}
