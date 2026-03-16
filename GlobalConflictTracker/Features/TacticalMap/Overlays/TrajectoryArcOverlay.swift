import SwiftUI
import MapKit

/// Renders a curved trajectory arc on the map with an animated projectile and impact marker.
/// Used for missile strikes, airstrikes, and drone strikes.
struct TrajectoryArcOverlay: MapContent {
    let event: ConflictEvent
    let trajectory: TrajectoryData
    let isSelected: Bool

    var body: some MapContent {
        let arcPoints = GeoMath.arcPoints(
            from: trajectory.origin.coordinate,
            to: trajectory.destination.coordinate,
            segments: 50,
            arcHeight: trajectory.arcHeight
        )

        let color = AppColors.severityColor(event.severity)

        // Arc polyline
        MapPolyline(coordinates: arcPoints)
            .stroke(color.opacity(isSelected ? 0.9 : 0.6), lineWidth: isSelected ? 3 : 2)

        // Origin marker
        Annotation(
            trajectory.originLabel,
            coordinate: trajectory.origin.coordinate,
            anchor: .center
        ) {
            OriginMarkerView(
                label: trajectory.originLabel,
                color: color,
                showLabel: isSelected
            )
        }

        // Destination impact marker
        Annotation(
            trajectory.destinationLabel,
            coordinate: trajectory.destination.coordinate,
            anchor: .center
        ) {
            ImpactMarkerView(color: color, size: 36)
        }

        // Midpoint weapon label
        if let weaponType = trajectory.weaponType {
            let midpoint = GeoMath.interpolate(along: arcPoints, at: 0.5)
            Annotation(weaponType, coordinate: midpoint, anchor: .bottom) {
                TrajectoryLabelView(text: weaponType, color: color)
            }
        }

        // Animated projectile
        Annotation("projectile", coordinate: trajectory.origin.coordinate, anchor: .center) {
            ProjectileView(arcPoints: arcPoints, color: color, isActive: trajectory.isActive)
        }
    }
}

// MARK: - Origin Marker

private struct OriginMarkerView: View {
    let label: String
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
                    .fill(color.opacity(0.3))
                    .frame(width: 16, height: 16)
                Circle()
                    .stroke(color, lineWidth: 1.5)
                    .frame(width: 16, height: 16)
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Trajectory Label

private struct TrajectoryLabelView: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 8, weight: .bold))
            .tracking(1.5)
            .foregroundStyle(color)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(AppColors.surface.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(color.opacity(0.4), lineWidth: 0.5)
            )
            .allowsHitTesting(false)
    }
}

// MARK: - Animated Projectile

private struct ProjectileView: View {
    let arcPoints: [CLLocationCoordinate2D]
    let color: Color
    let isActive: Bool

    @State private var progress: Double = 0
    @State private var currentPosition: CLLocationCoordinate2D?
    @State private var showProjectile = true

    private let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if showProjectile {
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                        .shadow(color: color, radius: 6)
                    Circle()
                        .fill(.white)
                        .frame(width: 4, height: 4)
                }
            } else {
                Color.clear.frame(width: 1, height: 1)
            }
        }
        .onReceive(timer) { _ in
            guard showProjectile else { return }
            progress += 0.008
            if progress >= 1.0 {
                showProjectile = false
            }
        }
        .onChange(of: progress) {
            // Position updates are handled by the parent Annotation coordinate
            // This view just controls visibility and glow
        }
    }
}
