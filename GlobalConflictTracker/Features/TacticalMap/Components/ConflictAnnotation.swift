import SwiftUI

/// Custom map annotation marker differentiated by event type
/// Features: pulsing ring for critical, event type icon, severity color, selection glow, label
struct ConflictAnnotation: View {
    let event: ConflictEvent
    var isSelected: Bool = false
    var zoomLevel: Double = 10.0

    @State private var isPulsing = false

    /// Whether to show the compact label based on zoom level and severity
    private var showCompactLabel: Bool {
        if isSelected { return false } // Selected shows full label instead
        switch event.severity {
        case .critical: return zoomLevel < 30 // Almost always visible
        case .warning: return zoomLevel < 15  // Visible at region zoom
        case .low: return zoomLevel < 5       // Only visible when zoomed in
        }
    }

    private var size: CGFloat {
        if isSelected { return 40 }
        return event.severity == .critical ? 32 : 24
    }

    private var markerColor: Color {
        AppColors.severityColor(event.severity)
    }

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                // Selection glow
                if isSelected {
                    Circle()
                        .fill(markerColor.opacity(0.25))
                        .frame(width: size + 24, height: size + 24)

                    Circle()
                        .stroke(markerColor, lineWidth: 2)
                        .frame(width: size + 20, height: size + 20)
                }

                // Outer pulse ring for critical events
                if event.severity == .critical {
                    Circle()
                        .fill(markerColor.opacity(0.2))
                        .frame(width: size + 16, height: size + 16)
                        .scaleEffect(isPulsing ? 1.5 : 1.0)
                        .opacity(isPulsing ? 0 : 0.8)
                        .animation(
                            .easeOut(duration: 2.0).repeatForever(autoreverses: false),
                            value: isPulsing
                        )
                }

                // Severity ring
                Circle()
                    .fill(markerColor.opacity(0.3))
                    .frame(width: size + 8, height: size + 8)

                // Core marker with border
                Circle()
                    .fill(markerColor)
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: markerColor.opacity(0.6), radius: isSelected ? 8 : 4)

                // Type icon
                Image(systemName: event.eventType.icon)
                    .font(.system(size: size * 0.38, weight: .bold))
                    .foregroundStyle(.white)
            }

            // Marker pin tail
            Triangle()
                .fill(markerColor)
                .frame(width: 10, height: 6)
                .shadow(color: markerColor.opacity(0.5), radius: 2)

            // Compact always-visible label (zoom-dependent)
            if showCompactLabel {
                Text(event.compactLabel)
                    .font(.system(size: 8, weight: .bold))
                    .tracking(1.0)
                    .foregroundStyle(markerColor)
                    .lineLimit(1)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(AppColors.surface.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(markerColor.opacity(0.3), lineWidth: 0.5)
                    )
            }

            // Label — enriched info on selection
            if isSelected {
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.5)
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Text(event.eventType.rawValue.uppercased())
                            .font(.system(size: 7, weight: .semibold))
                            .foregroundStyle(AppColors.accent)

                        if !event.factionIDs.isEmpty {
                            Text("•")
                                .font(.system(size: 7))
                                .foregroundStyle(AppColors.textTertiary)
                            Text("\(event.factionIDs.count) FACTION\(event.factionIDs.count > 1 ? "S" : "")")
                                .font(.system(size: 7, weight: .semibold))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }

                    Text(RelativeTimeFormatter.string(from: event.timestamp))
                        .font(.system(size: 7, weight: .medium))
                        .foregroundStyle(AppColors.textTertiary)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(AppColors.surface.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .frame(maxWidth: 160)
            }
        }
        .onAppear {
            if event.severity == .critical {
                isPulsing = true
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isSelected)
        .accessibilityLabel("\(event.severity.label) \(event.eventType.accessibilityLabel): \(event.title)")
    }
}

/// Small triangle for marker pin tail
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview("Annotations") {
    HStack(spacing: 40) {
        ConflictAnnotation(event: SampleData.events[0], isSelected: true)
        ConflictAnnotation(event: SampleData.events[1])
        ConflictAnnotation(event: SampleData.events[2])
        ConflictAnnotation(event: SampleData.events[3])
    }
    .padding(40)
    .background(Color(red: 0.1, green: 0.15, blue: 0.1))
    .preferredColorScheme(.dark)
}
