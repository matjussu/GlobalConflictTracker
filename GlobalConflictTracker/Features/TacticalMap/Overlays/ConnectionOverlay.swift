import SwiftUI
import MapKit

/// Renders a dashed connection line between two points with an animated pulse.
/// Used for cyber attacks and data connections.
struct ConnectionOverlay: MapContent {
    let event: ConflictEvent
    let connectionData: ConnectionData
    let isSelected: Bool

    var body: some MapContent {
        let color = event.eventType.color

        // Connection line
        MapPolyline(coordinates: [
            connectionData.source.coordinate,
            connectionData.target.coordinate,
        ])
        .stroke(color.opacity(isSelected ? 0.7 : 0.4), lineWidth: isSelected ? 2.5 : 1.5)

        // Source marker
        Annotation(
            connectionData.sourceLabel,
            coordinate: connectionData.source.coordinate,
            anchor: .center
        ) {
            ConnectionEndpointView(
                label: connectionData.sourceLabel,
                icon: "arrow.up.forward.circle.fill",
                color: color,
                showLabel: isSelected
            )
        }

        // Target marker
        Annotation(
            connectionData.targetLabel,
            coordinate: connectionData.target.coordinate,
            anchor: .center
        ) {
            ConnectionEndpointView(
                label: connectionData.targetLabel,
                icon: "target",
                color: color,
                showLabel: isSelected
            )
        }

        // Animated pulse traveling along the line
        Annotation(
            "pulse",
            coordinate: connectionData.source.coordinate,
            anchor: .center
        ) {
            CyberPulseView(
                source: connectionData.source.coordinate,
                target: connectionData.target.coordinate,
                color: color
            )
        }

        // Midpoint label
        let midpoint = GeoMath.interpolate(
            along: [connectionData.source.coordinate, connectionData.target.coordinate],
            at: 0.5
        )
        Annotation(connectionData.connectionType, coordinate: midpoint, anchor: .bottom) {
            Text(connectionData.connectionType.uppercased().replacingOccurrences(of: "_", with: " "))
                .font(.system(size: 7, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(color)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(AppColors.surface.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .allowsHitTesting(false)
        }
    }
}

// MARK: - Connection Endpoint

private struct ConnectionEndpointView: View {
    let label: String
    let icon: String
    let color: Color
    let showLabel: Bool

    var body: some View {
        VStack(spacing: 2) {
            if showLabel {
                Text(label.components(separatedBy: ",").first ?? label)
                    .font(AppTypography.labelSmall)
                    .tracking(AppTypography.trackingWide)
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial)
                    .background(AppColors.surface.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 20, height: 20)
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(color)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Cyber Pulse Animation

private struct CyberPulseView: View {
    let source: CLLocationCoordinate2D
    let target: CLLocationCoordinate2D
    let color: Color

    @State private var phase: Double = 0
    private let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Multiple pulse dots at different phases
            ForEach(0..<3, id: \.self) { index in
                let offsetPhase = (phase + Double(index) * 0.33).truncatingRemainder(dividingBy: 1.0)
                Circle()
                    .fill(color)
                    .frame(width: 5, height: 5)
                    .shadow(color: color, radius: 4)
                    .opacity(offsetPhase < 0.9 ? 0.8 : 0.0)
            }
        }
        .onReceive(timer) { _ in
            phase += 0.012
            if phase >= 1.0 { phase = 0 }
        }
    }
}
