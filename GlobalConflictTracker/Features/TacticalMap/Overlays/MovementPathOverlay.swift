import SwiftUI
import MapKit

/// Renders a multi-waypoint movement path with direction arrows and a current position indicator.
/// Used for fleet movements and troop deployments.
struct MovementPathOverlay: MapContent {
    let event: ConflictEvent
    let pathData: MovementPathData
    let isSelected: Bool

    var body: some MapContent {
        let coordinates = pathData.waypoints.map(\.coordinate)
        let color = event.eventType.color

        // Completed path segment (origin to current position)
        let completedCount = max(2, Int(Double(coordinates.count) * pathData.progressFraction))
        let completedCoords = Array(coordinates.prefix(completedCount))
        MapPolyline(coordinates: completedCoords)
            .stroke(color.opacity(isSelected ? 0.8 : 0.6), lineWidth: 3)

        // Remaining path segment (current position to destination) — dashed
        if completedCount < coordinates.count {
            let remainingCoords = Array(coordinates.suffix(from: max(0, completedCount - 1)))
            MapPolyline(coordinates: remainingCoords)
                .stroke(color.opacity(0.25), lineWidth: 2)
        }

        // Direction arrows at intervals along the path
        let arrowIndices = stride(from: 1, to: coordinates.count - 1, by: max(1, coordinates.count / 4))
        for index in arrowIndices {
            let position = coordinates[index]
            let nextIndex = min(index + 1, coordinates.count - 1)
            let bearing = GeoMath.bearing(from: coordinates[index], to: coordinates[nextIndex])

            Annotation("direction", coordinate: position, anchor: .center) {
                Image(systemName: "arrowtriangle.forward.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(color.opacity(0.6))
                    .rotationEffect(.degrees(bearing - 90))
                    .allowsHitTesting(false)
            }
        }

        // Current position marker (pulsing)
        let currentPos = GeoMath.interpolate(along: coordinates, at: pathData.progressFraction)
        Annotation(
            pathData.assetType ?? "Asset",
            coordinate: currentPos,
            anchor: .center
        ) {
            CurrentPositionMarker(
                label: pathData.assetType,
                color: color,
                showLabel: isSelected
            )
        }

        // Origin label
        if let firstCoord = coordinates.first {
            Annotation(pathData.originLabel, coordinate: firstCoord, anchor: .top) {
                PathEndpointLabel(text: pathData.originLabel, color: color)
            }
        }

        // Destination label
        if let lastCoord = coordinates.last, let destLabel = pathData.destinationLabel {
            Annotation(destLabel, coordinate: lastCoord, anchor: .top) {
                PathEndpointLabel(text: destLabel, color: color)
            }
        }
    }
}

// MARK: - Current Position Marker

private struct CurrentPositionMarker: View {
    let label: String?
    let color: Color
    let showLabel: Bool

    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 2) {
            if showLabel, let label {
                Text(label)
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
                    .frame(width: 24, height: 24)
                    .scaleEffect(isPulsing ? 1.4 : 1.0)

                Circle()
                    .stroke(color.opacity(0.5), lineWidth: 1.5)
                    .frame(width: 18, height: 18)

                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .shadow(color: color.opacity(0.8), radius: 4)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Path Endpoint Label

private struct PathEndpointLabel: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text.components(separatedBy: ",").first ?? text)
            .font(.system(size: 8, weight: .semibold))
            .tracking(1.0)
            .foregroundStyle(color.opacity(0.8))
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(AppColors.surface.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .allowsHitTesting(false)
    }
}
